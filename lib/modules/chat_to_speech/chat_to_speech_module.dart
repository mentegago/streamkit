import 'dart:collection';
import 'package:flutter/services.dart';

import 'package:flutter_js/flutter_js.dart';
import 'package:just_audio/just_audio.dart';
import 'package:streamkit/modules/stream_kit_module.dart';

import 'models/chat_to_speech_configuration.dart';
import 'enums/language.dart';
import '../../utils/twitch/twitch.dart';

class ChatToSpeechMessage {
  final String name;
  final String message;
  final Language? language;

  ChatToSpeechMessage(
      {required this.name, required this.message, this.language});
}

class ChatToSpeechModule extends StreamKitModule {
  final maxQueueLength = 5;

  final _runtime = getJavascriptRuntime();
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
    // Load Franc
    rootBundle.loadString('assets/franc-min.js').then((script) {
      _runtime.evaluate(script);
    });

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
      final text = _pachify(
        _warafy(message.emotelessMessage),
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
    final language = message.language ?? _getLanguage(text: message.message);
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

  // Get language from Franc JavaScript library.
  Language _getLanguage({required String text}) {
    if (text.contains("panci panci panci")) {
      return Language.indonesian;
    }

    String francText = text;

    while (francText.length < 30 && francText.isNotEmpty) {
      francText += " " + text;
    }

    String languages = (_configuration?.languages ?? [])
        .map((lang) => "'" + lang.franc + "'")
        .join(", ");

    final textLanguage = _runtime
        .evaluate("franc('" +
            francText.replaceAll('\'', '\\\'') +
            "', { whitelist: [$languages] })")
        .stringResult;

    return LanguageParser.fromFranc(textLanguage) ??
        ((_configuration?.languages ?? []).isNotEmpty
            ? (_configuration?.languages ?? []).first
            : Language.indonesian);
  }

  String _pachify(String text, {String username = ""}) {
    final usernameList = [
      'ngeq',
      'amikarei',
      'bagusnl',
      'ozhy27',
      'kalamuspls',
      'seiki_ryuuichi',
      'cepp18_',
      'mentegagoreng',
      'sodiumtaro'
    ];

    String pachiReplacement = 'パチパチパチ';
    if (usernameList.contains(username.toLowerCase())) {
      pachiReplacement = 'panci panci panci';
    }

    return text.replaceAll(RegExp(r'(8|８){3,}'), pachiReplacement);
  }

  String _warafy(String text) {
    return text.replaceAll(
      RegExp(r'(( |^|\n|\r)(w|ｗ){2,}( |$|\n|\r))'),
      'わらわら',
    );
  }
}
