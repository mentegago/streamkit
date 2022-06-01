import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/twitch/twitch_message.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';
import 'package:streamkit_tts/utils/beat_saver_util.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/language_detection_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';
import 'package:uuid/uuid.dart';

class ChatToSpeechMessage {
  final String message;
  final Language language;
  final bool
      disallowDequeue; // When queue exceeds maxMessageQueueLength, allow this message to be removed from queue.
  final bool
      disallowSpeedUp; // Disallow this message to be played faster than 1x.
  File? audio;
  Duration? audioDuration;

  ChatToSpeechMessage({
    required this.message,
    required this.language,
    this.disallowDequeue = false,
    this.disallowSpeedUp = false,
  });
}

class ChatToSpeechService extends ChangeNotifier {
  final _player = AudioPlayer();
  final _durationCheckPlayer =
      AudioPlayer(); // Used to check duration of audio.

  // Utils
  final LanguageDetection _languageDetectionUtil;
  final ExternalConfig _externalConfigUtil;
  final MiscTts _miscTtsUtil;
  final BeatSaverUtil _beatSaverUtil;

  late String _streamKitDir;

  final _maxMessageQueueLength = 15;
  final _maxCharacterLength =
      120; // Important due to Google Translate API limit.
  final _maxMessageQueueTotalDurationMilliseconds = 20000;
  final _maxMessageDurationMilliseconds = 8000;
  final double _maxMessageSpeedUpFactor = 5;
  final double _minMessageSpeedUpFactor = 1;

  final _twitch = TwitchChatService();
  final _messageQueue = Queue<ChatToSpeechMessage>();

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
    required BeatSaverUtil beatSaverUtil,
  })  : _config = config,
        _languageDetectionUtil = languageDetectionUtil,
        _externalConfigUtil = externalConfigUtil,
        _miscTtsUtil = miscTtsUtil,
        _beatSaverUtil = beatSaverUtil {
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
      while (_messageQueue.isNotEmpty) {
        final message = _messageQueue.removeFirst();
        _cleanMessage(message);
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
        ? message.emotelessMessage.trim()
        : message.message.trim();

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
      spokenText = "${message.username.replaceAll("_", " ")}, $spokenText";
    }

    // Username fixing.
    spokenText = _fixNames(language, spokenText);

    if (spokenText.length > _maxCharacterLength) {
      spokenText = spokenText.substring(0, _maxCharacterLength);
    }

    spokenText = spokenText.replaceAll(RegExp(r"[:*><();^~`\[\]]"), "");

    _addMessageToQueue(
      ChatToSpeechMessage(
        message: spokenText,
        language: language,
      ),
    );
  }

  String _fixNames(Language language, String spokenText) {
    for (var name in _externalConfigUtil.nameFixConfig.names) {
      final replacedName = () {
        switch (language) {
          case Language.english:
            return name.en;
          case Language.indonesian:
            return name.id;
          case Language.japanese:
            return name.jp;
          case Language.french:
            return name.fr;
        }
      }();
      spokenText =
          spokenText.replaceAll(name.original, replacedName ?? name.original);
    }
    return spokenText;
  }

  _handleCommand(TwitchMessage message) {
    if (message.username == "mentegagoreng") {
      // StreamKit admin commands.
      if (message.message == "!updatepancilist") {
        _externalConfigUtil.loadPanciList();
        return;
      }

      if (message.message == "!updatenamefixlist") {
        _externalConfigUtil.loadNameFixList();
        return;
      }
    }

    final commandSplit = message.message.toLowerCase().split(' ');

    if (_config.chatToSpeechConfiguration.readBsr &&
        commandSplit.length == 2 &&
        commandSplit[0] == "!bsr") {
      final bsrCode = commandSplit[1];
      _beatSaverUtil.getSongName(bsrCode: bsrCode).then((songName) {
        final filteredSongName = _config.chatToSpeechConfiguration.readBsrSafely
            ? "a song"
            : songName;
        _addMessageToQueue(
          ChatToSpeechMessage(
            message: _fixNames(
              Language.english,
              "${message.username.replaceAll("_", " ")} requested $filteredSongName",
            ),
            language: Language.english,
          ),
        );
      });
      return;
    }
  }

  void _addMessageToQueue(ChatToSpeechMessage message) {
    while (_messageQueue.length > _maxMessageQueueLength) {
      final message =
          _messageQueue.firstWhereOrNull((element) => !element.disallowDequeue);
      if (message == null) break;

      _messageQueue.remove(message);
      _cleanMessage(message);
    }
    _messageQueue.add(message);
    _performMessageQueueDownload();
  }

  void _cleanMessage(ChatToSpeechMessage message) {
    message.audio?.delete();
  }

  void _performMessageAudioQueueSpeak() async {
    if (_isSpeaking) return;

    final message =
        _messageQueue.firstWhereOrNull((element) => element.audio != null);
    final audioFile = message?.audio;

    if (message == null || audioFile == null) return;

    final queueAudioDuration = _messageQueue
        .where((element) => element.audioDuration != null)
        .fold<int>(
            0,
            (previousValue, element) =>
                previousValue +
                min(element.audioDuration?.inMilliseconds ?? 0,
                    _maxMessageDurationMilliseconds));
    _isSpeaking = true;
    _messageQueue.remove(message);

    if (_player.playerState.playing) await _player.stop();
    await _player.setAudioSource(AudioSource.uri(audioFile.uri));
    final duration = _player.duration?.inMilliseconds ?? 0;
    // final audioSpeed = duration <= 8 ? 1.0 : min(duration / 8.0, 2.0);
    final audioSpeed = message.disallowSpeedUp
        ? 1.0
        : max(duration / _maxMessageDurationMilliseconds,
            queueAudioDuration / _maxMessageQueueTotalDurationMilliseconds);
    await _player.setSpeed(max(
      min(
        audioSpeed,
        _maxMessageSpeedUpFactor,
      ),
      _minMessageSpeedUpFactor,
    ));
    await _player.play();

    await _player.processingStateStream.firstWhere((element) =>
        element ==
        ProcessingState.completed); // Wait until audio playback is complete.

    _cleanMessage(message);
    _isSpeaking = false;
    _performMessageAudioQueueSpeak();
  }

  void _performMessageQueueDownload() async {
    if (_isDownloading) return;
    final message =
        _messageQueue.firstWhereOrNull((element) => element.audio == null);

    if (message == null) return;

    _isDownloading = true;
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
      message.audio = file;
      await _durationCheckPlayer.stop();
      await _durationCheckPlayer.setAudioSource(AudioSource.uri(file.uri));
      if ((_durationCheckPlayer.duration?.inSeconds ?? 0) < 60) {
        message.audioDuration = _durationCheckPlayer.duration;
      }
    } else {
      _messageQueue.remove(message);
    }

    _isDownloading = false;
    _performMessageAudioQueueSpeak();
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
