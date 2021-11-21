import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:web_socket_channel/io.dart';

import '../modules/chat_to_speech/models/twitch-message.dart';
import '../modules/chat_to_speech/models/user_state.dart';

enum TwitchState { active, inactive, loading }
enum TwitchError { timeout }

class Twitch {
  final String _nick;
  final String? _token;

  Set<String> _channels = {};
  Set<String> _targetChannels;

  IOWebSocketChannel? _wsChannel;

  final _messageSubject = PublishSubject<TwitchMessage>();
  final _joinSubject = PublishSubject<String>();
  final _partSubject = PublishSubject<String>();
  final _state = BehaviorSubject<TwitchState>();
  final _error = PublishSubject<TwitchError>();

  Stream<TwitchMessage> get messageStream => _messageSubject.stream;
  Stream<String> get joinStream => _joinSubject.stream;
  Stream<String> get partStream => _partSubject.stream;

  Stream<TwitchState> get state => _state.stream;
  Stream<TwitchError> get error => _error.stream;

  Set<String> get channels => _channels;

  Twitch(
      {String username = "justinfan24",
      String? token,
      Set<String> channels = const <String>{}})
      : _nick = username,
        _token = token,
        _targetChannels = channels {
    _connect();
  }

  void _connect() {
    final wsChannel = IOWebSocketChannel.connect(
        Uri.parse('wss://irc-ws.chat.twitch.tv:443'));
    wsChannel.sink.add('NICK $_nick');
    wsChannel.sink.add("CAP REQ :twitch.tv/tags");

    // Connect to currently set channels.
    setChannels(_targetChannels.toList());

    wsChannel.stream.listen(
      (event) {
        event.toString().split('\r\n').forEach((line) {
          final genericRegex = RegExp(
            "(?<tags>.*):(?<username>[^!]+)![^ ]* (?<type>[^ ]+) #(?<channel>[^ ]+)( :){0,1}(?<message>.*)",
            unicode: true,
          );

          if (line.startsWith("PING :")) {
            wsChannel.sink.add("PONG :tmi.twitch.tv");
          }

          final match = genericRegex.firstMatch(line);
          if (match != null) {
            final type = match.namedGroup('type');
            switch (type) {
              case 'JOIN':
                _handleJoinMessage(match);
                break;
              case 'PART':
                _handlePartMessage(match);
                break;
              case 'PRIVMSG':
                _handlePrivateMessage(match);
                break;
              default:
                break;
            }
          }
        });
      },
      onDone: () => _reconnectAttempt(error: false),
      onError: (_) => _reconnectAttempt(error: true),
    );

    _wsChannel = wsChannel;
  }

  void _reconnectAttempt({required bool error}) {
    if (_wsChannel?.closeCode == 1005 && !error) return;
    _wsChannel?.sink.close();
    _wsChannel = null;

    Future.delayed(const Duration(seconds: 1)).then((_) {
      _connect();
    });
  }

  void _handlePrivateMessage(RegExpMatch match) {
    if (_state.value != TwitchState.active) {
      return; // Ignore any message unless module is active.
    }

    final tags = match.namedGroup('tags') ?? "";
    final username = match.namedGroup('username') ?? "";
    final channel = match.namedGroup('channel') ?? "";
    final message = match.namedGroup('message') ?? "";
    final userState = UserState.fromString(tags);

    final emotes = userState.emotes
        .map((emote) => message.substring(emote.startIndex, emote.endIndex + 1))
        .toSet();

    final emotelessMessage = emotes
        .fold(
            message,
            (String previousValue, element) =>
                previousValue.replaceAll(element, ''))
        .replaceAll(RegExp(" +"), " "); // remove multiple spaces

    _messageSubject.add(
      TwitchMessage(message,
          username: username,
          userState: userState,
          channel: channel,
          self: username == _nick,
          emotelessMessage: emotelessMessage),
    );
  }

  void _handleJoinMessage(RegExpMatch match) {
    final user = match.namedGroup("username");
    final channel = match.namedGroup("channel");

    if (user == _nick && channel != null) {
      _channels.add(channel);
      _joinSubject.add(channel);

      _updateModuleState();
    }
  }

  void _handlePartMessage(RegExpMatch match) {
    final user = match.namedGroup("username");
    final channel = match.namedGroup("channel");

    if (user == _nick && channel != null) {
      _channels.remove(channel);
      _partSubject.add(channel);

      _updateModuleState();
    }
  }

  void setChannels(List<String> channels) {
    final currentChannels = _channels;

    // Leave current channels.
    currentChannels
        .where((channel) => !channels.contains(channel))
        .forEach((channel) => _wsChannel?.sink.add("PART #$channel"));

    // Join new channels.
    channels
        .where((channel) => !currentChannels.contains(channel))
        .forEach((channel) => _wsChannel?.sink.add("JOIN #$channel"));

    _targetChannels = channels.toSet();
    _updateModuleState();
  }

  void leaveAllChannels() {
    for (var element in _channels) {
      _wsChannel?.sink.add("PART #$element");
    }

    _targetChannels = {};
  }

  void _updateModuleState() {
    if (_targetChannels.isEmpty) {
      return _state.add(TwitchState.inactive);
    }

    if (setEquals(_targetChannels, _channels)) {
      return _state.add(TwitchState.active);
    }

    Future.delayed(const Duration(seconds: 5)).then((_) {
      if (_state.value == TwitchState.loading) {
        _error.add(TwitchError.timeout);
        setChannels([]);
      }
    });

    return _state.add(TwitchState.loading);
  }
}
