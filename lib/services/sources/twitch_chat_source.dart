import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:twitch_chat/twitch_chat.dart';
import 'package:web_socket_channel/io.dart';

import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart'
    as streamkit;

abstract class SourceService {
  Stream<streamkit.Message> getMessageStream();
  Stream<SourceStatus> getStatusStream();
}

enum SourceStatus { inactive, active }

class TwitchChatSource implements SourceService {
  final _messageSubject = PublishSubject<streamkit.Message>();
  final _statusSubject = PublishSubject<SourceStatus>();
  final Config _config;

  TwitchChat? _twitchChat;

  IOWebSocketChannel? _wsChannel;

  TwitchChatSource({required Config config}) : _config = config {
    _config.addListener(_onConfigChange);
    _onConfigChange();
  }

  @override
  Stream<streamkit.Message> getMessageStream() {
    return _messageSubject.stream;
  }

  @override
  Stream<SourceStatus> getStatusStream() {
    return _statusSubject.stream;
  }

  void _onConfigChange() {
    if (_config.chatToSpeechConfiguration.enabled) {
      connect(channel: _config.chatToSpeechConfiguration.channels.first);
    } else {
      disconnect();
    }
  }

  void connect({required String channel}) async {
    if (_twitchChat == null) {
      final twitchChat = TwitchChat.anonymous(channel);
      _twitchChat = twitchChat;
      twitchChat.connect();

      twitchChat.isConnected.addListener(() {
        if (twitchChat.isConnected.value) {
          _statusSubject.add(SourceStatus.active);
        } else {
          _statusSubject.add(SourceStatus.inactive);
        }
      });

      twitchChat.chatStream.map((message) {
        return streamkit.ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: message.username,
          suggestedSpeechMessage: message.message,
          language: Language.indonesian,
          rawMessage: message.message,
          messageWithoutEmotes: message.message,
        );
      }).listen((message) {
        _messageSubject.add(message);
      });

      twitchChat.onError = () {
        _statusSubject.add(SourceStatus.inactive);
        disconnect();
        connect(channel: channel);
      };

      twitchChat.onDone = () {
        _statusSubject.add(SourceStatus.inactive);
        disconnect();
      };
    } else if (channel != _twitchChat?.channel) {
      _twitchChat?.changeChannel(channel);
    }
  }

  void disconnect() {
    _twitchChat?.close();
    _twitchChat = null;
  }
}
