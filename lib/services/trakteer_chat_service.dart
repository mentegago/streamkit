import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/trakteer/TrakteerBroadcastNotification.dart';
import 'package:web_socket_channel/io.dart';

import 'package:http/http.dart' as http;

enum TrakteerState { active, inactive, loading }

enum TrakteerError {
  subscriptionError,
  invalidUrl,
  httpError,
  httpParseFail,
  timeout
}

class TrakteerChatService {
  IOWebSocketChannel? _wsChannel;
  Timer? _pingTimer;

  final _state = BehaviorSubject<TrakteerState>();
  final _error = PublishSubject<TrakteerError>();
  final _messageStream = PublishSubject<TrakteerBroadcastNotification>();

  Stream<TrakteerState> get state => _state.stream;
  Stream<TrakteerError> get error => _error.stream;
  Stream<TrakteerBroadcastNotification> get messageStream =>
      _messageStream.stream;

  final Set<String> _targetChannels = {};
  final Set<String> _connectedChannels = {};

  bool _isConnectionEstablished = false;

  TrakteerChatService() {}

  void subscribeChannels(Set<String> channels) {
    _targetChannels.addAll(channels);
    _connectToTargetChannels();
  }

  void subscribeNotificationUrl(String notificationUrl) async {
    try {
      final url = Uri.parse(notificationUrl);
      final response = await http.get(url, headers: {
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US;en;q=0.5',
        'Connection': 'keep-alive',
        'Host': 'trakteer.id',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'MentegaStreamKit',
      });

      if (response.statusCode != 200) {
        _error.add(TrakteerError.httpError);
        return;
      }

      final channelRegex = RegExp(r"Echo.channel\(\'([^\']+)\'\)");
      final channelMatches = channelRegex.allMatches(response.body);
      final channels = channelMatches
          .map((e) => e.group(1))
          .where((element) => element != null)
          .map((e) => e as String)
          .toSet();

      if (channels.isEmpty) {
        _error.add(TrakteerError.httpParseFail);
        return;
      }

      subscribeChannels(channels);
    } on FormatException {
      _error.add(TrakteerError.invalidUrl);
      return;
    } catch (e) {
      _error.add(TrakteerError.httpError);
      return;
    }
  }

  void _connect({
    int reconnectDelaySeconds = 1,
    int attempt = 0,
    int maxAttempts = 5,
  }) {
    if (_targetChannels.isEmpty) {
      _disconnect();
      return;
    }

    _state.add(TrakteerState.loading);

    final wsChannel = IOWebSocketChannel.connect(Uri.parse(
      'wss://socket.trakteer.id/app/2ae25d102cc6cd41100a?protocol=7&client=js&version=5.1.1&flash=false',
    ));

    wsChannel.stream.listen(
      (event) {
        _setupPingTimer();
        _handleEvents(jsonDecode(event));
      },
      onDone: () {
        _disconnect();
        _error.add(TrakteerError.timeout);
      },
      onError: (_) {
        if (attempt >= maxAttempts) {
          _disconnect();
          return;
        }

        // Reconnect in reconnectDelay seconds
        Timer(Duration(seconds: reconnectDelaySeconds), () {
          _connect(
            reconnectDelaySeconds: reconnectDelaySeconds * 2,
            attempt: attempt + 1,
            maxAttempts: maxAttempts,
          );
        });
      },
    );

    _wsChannel = wsChannel;
  }

  void _disconnect() {
    _pingTimer?.cancel();
    _wsChannel?.sink.close();

    _pingTimer = null;
    _wsChannel = null;

    _isConnectionEstablished = false;
    _targetChannels.clear();
    _connectedChannels.clear();

    _state.add(TrakteerState.inactive);
  }

  void _handleEvents(Map<String, dynamic> event) {
    String eventName = event['event'];
    print(event);
    switch (eventName) {
      case 'pusher:connection_established':
        _isConnectionEstablished = true;
        if (_targetChannels.isEmpty) {
          _disconnect(); // No need to be connected if no channels are connected.
          return;
        }

        _connectToTargetChannels();
        break;
      case 'pusher:subscription_succeeded':
        _connectedChannels.add(event['channel']);
        _state.add(TrakteerState.active);
        break;
      case 'subscription_error':
        _error.add(TrakteerError.subscriptionError);
        _disconnect();
        break;
      case 'Illuminate\\Notifications\\Events\\BroadcastNotificationCreated':
        final notification =
            TrakteerBroadcastNotification.fromJson(event['data']);
        _messageStream.add(notification);
        print(notification);
        break;
      default:
        break;
    }
  }

  void _connectToTargetChannels() {
    if (_wsChannel == null) {
      _connect();
      return;
    }

    if (!_isConnectionEstablished) {
      return;
    }

    for (var channel in _targetChannels) {
      _joinChannel(channel);
    }
  }

  void _setupPingTimer() {
    if (_pingTimer != null) return;
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendPing();
    });
  }

  void _sendPing() {
    _wsChannel?.sink.add('{"event":"pusher:ping","data":""}');
  }

  void _joinChannel(String channel) {
    _wsChannel?.sink
        .add('{"event":"pusher:subscribe","data":{"channel":"$channel"}}');
  }

  void _updateState() {
    if (setEquals(_targetChannels, _connectedChannels)) {
      _state.add(TrakteerState.active);
    }
  }
}
