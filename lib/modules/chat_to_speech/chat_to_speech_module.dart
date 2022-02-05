import 'dart:collection';
import 'dart:convert';

import 'package:just_audio/just_audio.dart';
import 'package:streamkit/app_config.dart';
import 'package:streamkit/configurations/chat_to_speech_configuration.dart';
import 'package:streamkit/modules/enums/language.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/screens/chat_to_speech/chat_to_speech.dart';
import 'package:streamkit/utils/beatsaver.dart';
import 'package:streamkit/utils/language.dart';
import 'package:streamkit/utils/string.dart';
import 'package:streamkit/utils/twitch.dart';

enum ChatToSpeechMessageType {
  message,
  bsr,
}

class ChatToSpeechMessage {
  final String name;
  final String message;
  final Language? language;
  final ChatToSpeechMessageType type;

  ChatToSpeechMessage({
    required this.name,
    required this.message,
    this.language,
    this.type = ChatToSpeechMessageType.message,
  });
}

class ChatToSpeechModule extends StreamKitModule {
  final maxQueueLength = 5;
  final _twitch = Twitch();
  final _messageQueue = Queue<ChatToSpeechMessage>();

  ChatToSpeechConfiguration? _configuration;
  bool _isSpeaking = false;

  Function(ChatToSpeechConfiguration configuration)? onConfigurationChanged;

  Set<String> get channels => _twitch.channels;
  Stream<String> get joinStream => _twitch.joinStream;
  Stream<ModuleState> get state => _twitch.state.map((event) {
        switch (event) {
          case TwitchState.active:
            return ModuleState.active;
          case TwitchState.inactive:
            return ModuleState.inactive;
          case TwitchState.loading:
            return ModuleState.loading;
        }
      });
  Stream<TwitchError> get error => _twitch.error;

  ChatToSpeechModule({this.onConfigurationChanged}) {
    _listenTwitchMessages();
  }

  void updateConfiguration(ChatToSpeechConfiguration configuration) {
    if (configuration.enabled) {
      _twitch.setChannels(configuration.channels);
    } else {
      _twitch.leaveAllChannels();
    }

    _configuration = configuration;
    onConfigurationChanged?.call(configuration);
  }

  void _listenTwitchMessages() {
    _twitch.messageStream.listen((message) {
      var text = StringUtil.pachify(
        StringUtil.warafy(message.emotelessMessage),
        username: message.username,
      );

      final splitText = text.split(' ');
      final forcedLanguage = splitText.length > 1
          ? LanguageParser.fromForceCode(splitText.first)
          : null;

      if (forcedLanguage != null) {
        splitText.removeAt(0);
        text = splitText.join(' ');
      }

      _addMessageToQueue(
        ChatToSpeechMessage(
            name: message.username, message: text, language: forcedLanguage),
      );

      // Check for !bsr code
      final readBsr = _configuration?.readBsr ?? true;
      final messageSplit = text.toLowerCase().split(' ');

      if (messageSplit[0] == '!bsr' && messageSplit.length == 2 && readBsr) {
        BeatSaverUtil.getSongName(bsrCode: messageSplit[1]).then((songName) {
          _addMessageToQueue(ChatToSpeechMessage(
            name: message.username,
            message: songName,
            language: Language.english,
            type: ChatToSpeechMessageType.bsr,
          ));
        }).catchError((error) {});
        return;
      }
    });
  }

  void _speak({required String text, required Language language}) async {
    final url = Uri(
        scheme: "https",
        host: "translate.google.com",
        path: "translate_tts",
        queryParameters: {
          "ie": "UTF-8",
          "q": text,
          "tl": language.google,
          "client": "tw-ob"
        });

    final player = AudioPlayer();
    await player.setUrl(url.toString());
    await player.setVolume(_configuration?.volume ?? 1.0);
    await player.play();

    await player.playerStateStream.firstWhere((event) =>
        event.processingState == ProcessingState.completed ||
        event.processingState == ProcessingState.idle);

    player.dispose();
    _readQueue();
  }

  void _readQueue() {
    if (_messageQueue.isEmpty) {
      _isSpeaking = false;
      return;
    }

    _isSpeaking = true;
    final message = _messageQueue.removeFirst();

    if (message.type == ChatToSpeechMessageType.message) {
      final language = message.language ??
          LanguageUtil.getLanguage(
              text: message.message,
              whitelistedLanguages: _configuration?.languages ?? {});
      final filteredName =
          message.name.replaceAll(RegExp("[^A-Za-z]"), "").toLowerCase();
      final text = (_configuration?.readUsername ?? true)
          ? filteredName + ", " + message.message
          : message.message;

      _speak(text: text, language: language);
    } else if (message.type == ChatToSpeechMessageType.bsr) {
      final text = "${message.name} requested ${message.message}";
      _speak(text: text, language: message.language ?? Language.english);
    }
  }

  void _addMessageToQueue(ChatToSpeechMessage message) {
    if (message.message == '!updatepancilist' &&
        message.name == 'mentegagoreng') {
      AppConfig.loadPanciList();
    }

    if ((_configuration?.ignoreExclamationMark ?? true) &&
        message.message.startsWith('!')) {
      return;
    }

    _messageQueue.add(message);

    // Keep queue below max queue limit.
    while (_messageQueue.length > maxQueueLength) {
      _messageQueue.removeFirst();
    }

    if (!_isSpeaking) {
      _readQueue();
    }
  }
}
