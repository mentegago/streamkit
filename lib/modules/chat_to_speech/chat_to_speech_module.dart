import 'dart:collection';

import 'package:just_audio/just_audio.dart';
import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/utils/language.dart';
import 'package:streamkit/utils/string.dart';

import 'models/chat_to_speech_configuration.dart';
import '../enums/language.dart';
import '../../utils/twitch.dart';

class ChatToSpeechMessage {
  final String name;
  final String message;
  final Language? language;

  ChatToSpeechMessage(
      {required this.name, required this.message, this.language});
}

class ChatToSpeechModule extends StreamKitModule {
  final maxQueueLength = 5;
  final _twitch = Twitch();
  final _messageQueue = Queue<ChatToSpeechMessage>();

  ChatToSpeechConfiguration? _configuration;
  bool _isSpeaking = false;

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

  ChatToSpeechModule() {
    _listenTwitchMessages();
  }

  void updateConfiguration(ChatToSpeechConfiguration configuration) {
    if (configuration.enabled) {
      _twitch.setChannels(configuration.channels);
    } else {
      _twitch.leaveAllChannels();
    }

    _configuration = configuration;
  }

  void _listenTwitchMessages() {
    _twitch.messageStream.listen((message) {
      final text = StringUtil.pachify(
        StringUtil.warafy(message.emotelessMessage),
        username: message.username,
      );

      _addMessageToQueue(
        ChatToSpeechMessage(name: message.username, message: text),
      );
    });
  }

  Future<Duration?> _speak(
      {required String text, required Language language}) async {
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
  }

  void _addMessageToQueue(ChatToSpeechMessage message) {
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
