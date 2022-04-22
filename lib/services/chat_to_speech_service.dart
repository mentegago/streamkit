import 'dart:collection';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/twitch/twitch_message.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/language_detection_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:uuid/uuid.dart';

class ChatToSpeechMessage {
  final String message;
  final Language language;

  ChatToSpeechMessage({
    required this.message,
    required this.language,
  });
}

class ChatToSpeechService extends ChangeNotifier {
  final _player = AudioPlayer();

  final LanguageDetection _languageDetectionUtil;
  final ExternalConfig _externalConfigUtil;
  final MiscTts _miscTtsUtil;

  late String _streamKitDir;

  final _maxMessageQueueLength = 5;
  final _maxCharacterLength =
      120; // Important due to Google Translate API limit.

  final _twitch = TwitchChatService();
  final _messageQueue = Queue<ChatToSpeechMessage>();
  final _messageAudioQueue = Queue<File>();

  final Config _config;

  var state = TwitchState.inactive;
  Stream<TwitchError> get errorStream => _twitch.error;
  var _isDownloading = false;
  var _isSpeaking = false;

  ChatToSpeechService({
    required Config config,
    required LanguageDetection languageDetectionUtil,
    required ExternalConfig externalConfigUtil,
    required MiscTts miscTtsUtil,
  })  : _config = config,
        _languageDetectionUtil = languageDetectionUtil,
        _externalConfigUtil = externalConfigUtil,
        _miscTtsUtil = miscTtsUtil {
    _config.addListener(_configChanged);
    _twitch.state.listen((event) {
      state = event;
      notifyListeners();
    });
    _twitch.error.listen((event) {
      _config.setEnabled(false);
    });
    _twitch.messageStream.listen(_messageReceived);

    getTemporaryDirectory().then((dir) {
      _streamKitDir = "${dir.path}\\StreamKitTmpAudio";
      _cleanUpAndPrepareStreamKitDir();
    });

    _configChanged();
  }

  void _configChanged() {
    if (_config.chatToSpeechConfiguration.enabled) {
      _twitch.setChannels(_config.chatToSpeechConfiguration.channels);
    } else {
      _twitch.leaveAllChannels();
      _messageQueue.clear();
      while (_messageAudioQueue.isNotEmpty) {
        final audioFile = _messageAudioQueue.removeFirst();
        audioFile.delete();
      }
    }

    _player.setVolume(_config.chatToSpeechConfiguration.volume / 100);
  }

  void _messageReceived(TwitchMessage message) {
    if (!_config.chatToSpeechConfiguration.enabled) return;

    if (message.message.startsWith("!")) {
      _handleCommand(message);
      if (_config.chatToSpeechConfiguration.ignoreExclamationMark) return;
    }

    String messageText = _config.chatToSpeechConfiguration.ignoreEmotes
        ? message.emotelessMessage
        : message.message;

    if (messageText.isEmpty) {
      return;
    }

    messageText = _miscTtsUtil.pachify(
      messageText,
      username: message.username,
      panciList: _externalConfigUtil.panciList,
    );
    messageText = _miscTtsUtil.warafy(messageText);

    final language = _getMessageLanguage(
      messageText,
      whitelistedLanguages: _config.chatToSpeechConfiguration.languages,
    );

    if (_getForceLanguageIfExists(messageText) != null) {
      messageText = messageText.substring(3);
    }

    String spokenText = messageText.toLowerCase();

    if (_config.chatToSpeechConfiguration.readUsername) {
      spokenText = "${message.username} $spokenText";
    }

    // Username fixing.
    for (var name in _externalConfigUtil.nameFixConfig.names) {
      final replacedName = () {
        switch (language) {
          case Language.english:
            return name.en;
          case Language.indonesian:
            return name.id;
          case Language.japanese:
            return name.jp;
        }
      }();
      spokenText = spokenText.replaceAll(name.original, replacedName);
    }

    if (spokenText.length > _maxCharacterLength) {
      spokenText = spokenText.substring(0, _maxCharacterLength);
    }

    _addMessageToQueue(
      ChatToSpeechMessage(
        message: spokenText,
        language: language,
      ),
    );
  }

  void _handleCommand(TwitchMessage message) {
    if (message.username.toLowerCase() != "mentegagoreng") return;
    if (message.message == "!updatepancilist") {
      _externalConfigUtil.loadPanciList();
      return;
    }

    if (message.message == "!updatenamefixlist") {
      _externalConfigUtil.loadNameFixList();
      return;
    }
  }

  void _addMessageToQueue(ChatToSpeechMessage message) {
    _messageQueue.add(message);
    _performMessageQueueDownload();
  }

  void _addAudioFileToQueue(File file) {
    while (_messageAudioQueue.length >= _maxMessageQueueLength) {
      final removedFile = _messageAudioQueue.removeFirst();
      removedFile.delete();
    }

    _messageAudioQueue.add(file);
    _performMessageAudioQueueSpeak();
  }

  void _performMessageAudioQueueSpeak() async {
    if (_isSpeaking || _messageAudioQueue.isEmpty) return;
    _isSpeaking = true;

    final audioFile = _messageAudioQueue.removeFirst();
    if (_player.playerState.playing) await _player.stop();
    await _player.setAudioSource(AudioSource.uri(audioFile.uri));
    await _player.play();

    await _player.processingStateStream.firstWhere((element) =>
        element ==
        ProcessingState.completed); // Wait until audio playback is complete.

    audioFile.delete();
    _isSpeaking = false;
    _performMessageAudioQueueSpeak();
  }

  void _performMessageQueueDownload() async {
    if (_isDownloading || _messageQueue.isEmpty) return;

    _isDownloading = true;
    final message = _messageQueue.removeFirst();
    final language = message.language;
    final spokenText = message.message;

    final url = Uri(
      scheme: "https",
      host: "translate.google.com",
      path: "translate_tts",
      queryParameters: {
        "ie": "UTF-8",
        "q": spokenText,
        "tl": language.google,
        "client": "tw-ob"
      },
    );

    final file = await _downloadFile(url, "${const Uuid().v4()}.mp3");
    if (file != null) {
      _addAudioFileToQueue(file);
    }

    _isDownloading = false;
    _performMessageQueueDownload();
  }

  Language? _getForceLanguageIfExists(String message) =>
      Language.values.firstWhereOrNull(
          (language) => message.startsWith("${language.forceCode} "));

  Language _getMessageLanguage(
    String text, {
    required Set<Language> whitelistedLanguages,
  }) =>
      _getForceLanguageIfExists(text) ??
      _languageDetectionUtil.getLanguage(text,
          whitelistedLanguages: whitelistedLanguages);

  Future<File?> _downloadFile(Uri url, String filename) async {
    http.Client client = http.Client();
    try {
      var req = await client.get(url);
      var bytes = req.bodyBytes;
      File file = File("$_streamKitDir\\$filename");
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  void _cleanUpAndPrepareStreamKitDir() {
    // Clean up
    final directory = Directory(_streamKitDir);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    directory.createSync();
  }
}
