import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'package:web_socket_channel/io.dart';

import '../models/twitch/twitch_message.dart';
import '../models/twitch/user_state.dart';

enum TwitchState { active, inactive, loading }

enum TwitchError { timeout }

// This script is taken from prior rewrite of StreamKit.
// May need to revisit this in the future.
// I'm treating this util as blackbox for now.

class TwitchChatService {
  final String _nick;
  final String? _token;

  final Set<String> _channels = {};
  Set<String> _targetChannels;

  Set<String> _globalBttvEmotes = {};
  final Map<String, Set<String>> _bttvEmotes = {};

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

  TwitchChatService({
    String username = "justinfan24",
    String? token,
    Set<String> channels = const <String>{},
  })  : _nick = username,
        _token = token,
        _targetChannels = channels {
    _connect();
    _fetchGlobalBttvEmotes();
  }

  void _connect() {
    final wsChannel = IOWebSocketChannel.connect(
        Uri.parse('wss://irc-ws.chat.twitch.tv:443'));
    wsChannel.sink.add('NICK $_nick');
    wsChannel.sink.add("CAP REQ :twitch.tv/tags");

    // Connect to currently set channels.
    setChannels(_targetChannels);

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
              case 'USERNOTICE':
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
    final userState = UserState.fromString(tags);

    String message = match.namedGroup('message') ?? "";

    message = message.replaceAll(
      RegExp(
          r"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"),
      "",
    );

    final twitchEmotes = userState.emotes
        .map((emote) => message.substring(emote.startIndex, emote.endIndex + 1))
        .toSet();

    final emotes = {
      ..._globalBttvEmotes,
      ..._bttvEmotes[channel] ?? {},
      ...twitchEmotes,
    };

    String emotelessMessage = emotes
        .fold(
          message,
          (String previousValue, element) =>
              previousValue.replaceAll(element, ''),
        )
        .replaceAll(RegExp(" +"), " "); // remove multiple spaces

    _messageSubject.add(
      TwitchMessage(
        message,
        username: username,
        userState: userState,
        channel: channel,
        self: username == _nick,
        emotelessMessage: emotelessMessage,
      ),
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

  void _fetchBttvEmotes(String channel) async {
    if (_bttvEmotes[channel] != null) return;
    final url = Uri.parse("https://decapi.me/bttv/emotes/$channel");
    final response = await http.get(url);
    if (response.statusCode != 200) return;

    final emotes = response.body.split(' ');
    _bttvEmotes[channel] = emotes.toSet();
  }

  void _fetchGlobalBttvEmotes() async {
    final url = Uri.parse("https://api.betterttv.net/3/cached/emotes/global");
    final response = await http.get(url);
    final List<dynamic> json = jsonDecode(response.body);

    _globalBttvEmotes = json.map((emote) => emote['code'] as String).toSet();
  }

  void setChannels(Set<String> targetChannels) {
    final currentChannels = _channels;
    final channels =
        targetChannels.map((channel) => channel.trim().toLowerCase()).toSet();

    // Leave current channels.
    currentChannels
        .where((channel) => !channels.contains(channel))
        .forEach((channel) => _wsChannel?.sink.add("PART #$channel"));

    // Join new channels.
    channels
        .where((channel) => !currentChannels.contains(channel))
        .forEach((channel) => _wsChannel?.sink.add("JOIN #$channel"));

    _targetChannels = channels.toSet();
    for (var channel in channels) {
      _fetchBttvEmotes(channel);
    }

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
        setChannels({});
      }
    });

    return _state.add(TwitchState.loading);
  }
}
