import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/models/twitch/twitch_message.dart';
import 'package:streamkit_tts/services/trakteer_chat_service.dart';
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
  final _chatToSpeechErrorMessage = PublishSubject<String>();

  late String _streamKitDir;

  final _maxMessageQueueLength = 100;
  final _maxCharacterLength =
      120; // Important due to Google Translate API limit.
  final _maxMessageQueueTotalDurationMilliseconds = 20000;
  final _maxMessageDurationMilliseconds = 10000;
  final double _maxMessageSpeedUpFactor = 2.5;
  final double _minMessageSpeedUpFactor = 1.0;

  final _twitch = TwitchChatService();
  final _trakteer = TrakteerChatService();
  final _messageQueue = Queue<ChatToSpeechMessage>();

  final Config _config;

  var state = TwitchState.inactive;
  Stream<TwitchError> get errorStream => _twitch.error;
  Stream<String> get chatToSpeechErrorMessage =>
      _chatToSpeechErrorMessage.stream;

  var _isDownloading = false;
  var _isSpeaking = false;

  var _lastMessageUsername = "";
  var _lastMessageTime = 0;

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

    _trakteer.messageStream.listen((notification) {
      String message =
          "${notification.supporterName} mentraktir ${notification.quantity} ${notification.unit}";

      if (notification.supporterMessage?.isNotEmpty ?? false) {
        message += "dengan pesan:";
      }

      _addMessageToQueue(
        ChatToSpeechMessage(
          message: message,
          language: Language.indonesian,
          disallowDequeue: true,
          disallowSpeedUp: true,
        ),
      );

      if (notification.supporterMessage?.isNotEmpty ?? false) {
        _addMessageToQueue(
          ChatToSpeechMessage(
            message: notification.supporterMessage ?? "",
            language: languageDetectionUtil.getLanguage(
              notification.supporterMessage ?? "",
              whitelistedLanguages: Language.values.toSet(),
            ),
            disallowDequeue: true,
            disallowSpeedUp: true,
          ),
        );
      }
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

    // If last message was sent by the same user, and it was less than 20 seconds ago, don't read the username. Else, respect the readUsername config.
    final shouldReadUsername = _config.chatToSpeechConfiguration.readUsername &&
        (_lastMessageUsername != message.username ||
            (DateTime.now().millisecondsSinceEpoch - _lastMessageTime >
                20 * 1000));

    if (shouldReadUsername) {
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

    _lastMessageUsername = message.username;
    _lastMessageTime = DateTime.now().millisecondsSinceEpoch;
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

  void _addMessageToQueue(
    ChatToSpeechMessage message, {
    bool sendToTop = false,
  }) {
    while (_messageQueue.length > _maxMessageQueueLength) {
      final message =
          _messageQueue.firstWhereOrNull((element) => !element.disallowDequeue);
      if (message == null) break;

      _messageQueue.remove(message);
      _cleanMessage(message);
    }

    if (sendToTop) {
      _messageQueue.addFirst(message);
    } else {
      _messageQueue.add(message);
    }

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

  Future<File?> _downloadFromTikTokTTS({
    required String speaker,
    required String text,
    required String filename,
  }) async {
    final uri = Uri.parse(
        "https://api22-normal-c-useast1a.tiktokv.com/media/api/text/speech/invoke/");

    final response = await http.post(
      uri,
      body: {
        'text_speaker': speaker,
        'req_text': text,
        'speaker_map_type': '0',
        'aid': '1234',
      },
      headers: {
        'User-Agent':
            'com.zhiliaoapp.musically/2022600030 (Linux; U; Android 7.1.2; es_ES; SM-G988N; Build/NRD90M;tt-ok/3.12.13.1)',
        'Cookie': 'sessionid=57b7d8b3e04228a24cc1e6d25387603a',
      },
    );

    if (response.statusCode != 200) {
      _config.setTtsSource(TtsSource.google);
      _chatToSpeechErrorMessage.add(
          "Failed to connect to TikTok TTS. StreamKit's TikTok TTS support is very unstable, so this is expected.\n\nStreamKit has automatically switched your speaker setting to Google Translate TTS to keep chat reader running.");
      return null;
    }

    try {
      final json = jsonDecode(response.body);
      if (json['data'] == null || json['data']['v_str'] == null) return null;
      return _fileFromBase64(json['data']['v_str'], filename);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _downloadFromGoogleTTS({
    required String text,
    required String language,
    required String filename,
  }) async {
    final url = Uri(
      scheme: "https",
      host: "translate.google.com",
      path: "translate_tts",
      queryParameters: {
        "ie": "UTF-8",
        "q": text,
        "tl": language,
        "client": "tw-ob"
      },
    );

    return await _downloadFile(url, "${const Uuid().v4()}.mp3");
  }

  void _performMessageQueueDownload() async {
    if (_isDownloading) return;
    final message =
        _messageQueue.firstWhereOrNull((element) => element.audio == null);

    if (message == null) return;

    _isDownloading = true;
    final language = message.language;
    final spokenText = message.message;

    final filename = "${const Uuid().v4()}.mp3";

    File? file;
    switch (_config.chatToSpeechConfiguration.ttsSource) {
      case TtsSource.google:
        file = await _downloadFromGoogleTTS(
          text: spokenText,
          language: language.google,
          filename: filename,
        );
        break;
      case TtsSource.tiktok:
        file = await _downloadFromTikTokTTS(
          speaker: language.tikTokSpeaker,
          text: spokenText,
          filename: filename,
        );

        // If TikTok TTS fail, fallback to Google TTS
        file ??= await _downloadFromGoogleTTS(
          text: spokenText,
          language: language.google,
          filename: filename,
        );

        break;
    }

    if (file != null) {
      message.audio = file;
      if (!message.disallowSpeedUp) {
        await _durationCheckPlayer.stop();
        await _durationCheckPlayer.setAudioSource(AudioSource.uri(file.uri));
        if ((_durationCheckPlayer.duration?.inSeconds ?? 0) < 60) {
          message.audioDuration = _durationCheckPlayer.duration;
        }
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

  Future<File> _fileFromBase64(String base64, String filename) async {
    final bytes = base64Decode(base64);
    File file = File("$_streamKitDir\\$filename");
    await file.writeAsBytes(bytes);
    return file;
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
