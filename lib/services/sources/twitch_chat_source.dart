import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart' as streamkit;
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/sources/source_service.dart';
import 'package:twitch_chat/twitch_chat.dart';
import 'package:http/http.dart' as http;

class TwitchChatSource implements SourceService {
  final _messageSubject = PublishSubject<Message>();
  final _statusSubject = PublishSubject<SourceStatus>();
  final Config _config;

  List<String> _globalBttvEmotes = [];
  List<String> _channelBttvEmotes = [];

  TwitchChat? _twitchChat;

  TwitchChatSource({required Config config}) : _config = config {
    _config.addListener(_onConfigChange);
    _onConfigChange();
  }

  @override
  Stream<Message> getMessageStream() {
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
      final twitchChat = TwitchChat(
        channel,
        'justinfan1243',
        '',
        onDone: () {
          _statusSubject.add(SourceStatus.inactive);
          disconnect();
        },
        onError: () {
          _statusSubject.add(SourceStatus.inactive);
          disconnect();
          connect(channel: channel);
        },
      );
      _twitchChat = twitchChat;
      twitchChat.connect();

      try {
        _fetchChannelBttvEmotes();
        _fetchGlobalBttvEmotes();
      } catch (_) {}

      twitchChat.isConnected.addListener(() {
        if (twitchChat.isConnected.value) {
          _statusSubject.add(SourceStatus.active);
        } else {
          _statusSubject.add(SourceStatus.inactive);
        }
      });

      twitchChat.chatStream.map((message) {
        final rawMessage = message.message.trim();
        final emotePositions = message.emotes.values.flattened
            .map((positions) {
              if (positions is! List<dynamic>) return null;
              if (positions.length != 2) return null;

              final startPosition = int.tryParse(positions.first);
              final endPosition = int.tryParse(positions.last);

              if (startPosition == null || endPosition == null) return null;

              return streamkit.EmotePosition(
                startPosition: startPosition,
                endPosition: endPosition,
              );
            })
            .nonNulls
            .toList();

        final thirdPartyEmotes = [..._globalBttvEmotes, ..._channelBttvEmotes];

        return streamkit.ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: message.username,
          suggestedSpeechMessage: rawMessage,
          rawMessage: rawMessage,
          emotePositions: emotePositions,
          emoteList: thirdPartyEmotes,
        );
      }).listen((message) {
        _messageSubject.add(message);
      });
    } else if (channel != _twitchChat?.channel) {
      disconnect();
      connect(channel: channel);
    }
  }

  void disconnect() {
    _twitchChat?.close();
    _twitchChat = null;
  }

  void _fetchChannelBttvEmotes() async {
    _channelBttvEmotes = [];

    try {
      final url = Uri.parse(
        "https://decapi.me/bttv/emotes/${_config.chatToSpeechConfiguration.channels.first}",
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return;
      if (response.body.toLowerCase().contains("unable to retrieve")) return;

      final emotes = response.body.split(' ');
      _channelBttvEmotes = emotes;
    } catch (_) {
      rethrow;
    }
  }

  void _fetchGlobalBttvEmotes() async {
    if (_globalBttvEmotes.isNotEmpty) return;

    try {
      final url = Uri.parse("https://api.betterttv.net/3/cached/emotes/global");
      final response = await http.get(url);
      final List<dynamic> json = jsonDecode(response.body);

      _globalBttvEmotes = json
          .where((emote) => emote['modifier'] == false)
          .map((emote) => emote['code'] as String)
          .toList();
    } catch (_) {
      rethrow;
    }
  }
}
