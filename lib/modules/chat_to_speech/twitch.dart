import 'dart:async';

import 'package:web_socket_channel/io.dart';

import 'models/twitch-message.dart';
import 'models/user_state.dart';

class Twitch {
  final _nick = "justinfan24";
  Set<String> _channels;
  IOWebSocketChannel? _wsChannel;

  final _messageController = StreamController<TwitchMessage>();
  final _joinController = StreamController<String>();

  Stream<TwitchMessage> get messageStream => _messageController.stream;
  Stream<String> get joinStream => _joinController.stream;

  Set<String> get channels => _channels;

  Twitch({Set<String> channels = const <String>{}}) : _channels = channels {
    _connect();
  }

  void _connect() {
    final wsChannel = IOWebSocketChannel.connect(
        Uri.parse('wss://irc-ws.chat.twitch.tv:443'));
    wsChannel.sink.add('NICK $_nick');
    wsChannel.sink.add("CAP REQ :twitch.tv/tags");

    // Connect to currently set channels.
    final currentChannels = _channels;
    _channels = <String>{};
    setChannels(currentChannels.toList());

    wsChannel.stream.listen(
      (event) {
        event.toString().split('\r\n').forEach((line) {
          print(line);

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

    _messageController.add(
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
      _joinController.sink.add(channel);
    }
  }

  void _handlePartMessage(RegExpMatch match) {
    final user = match.namedGroup("username");
    final channel = match.namedGroup("channel");

    if (user == _nick && channel != null) {
      _channels.remove(channel);
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
  }

  void leaveAllChannels() {
    for (var element in _channels) {
      _wsChannel?.sink.add("PART #$element");
    }
  }
}
