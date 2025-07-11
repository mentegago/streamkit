import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart' as streamkit;
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/sources/source_service.dart';
import 'package:streamkit_tts/utils/youtube_util.dart';

class YouTubeChatSource implements SourceService {
  final _messageSubject = PublishSubject<Message>();
  final _statusSubject = PublishSubject<SourceStatus>();
  final Config _config;

  String? _continuation;
  String? _apiKey;
  Map<String, dynamic>? _context;
  bool _isConnected = false;

  YouTubeChatSource({required Config config}) : _config = config {
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
    if (_config.chatToSpeechConfiguration.enabled &&
        _config.chatToSpeechConfiguration.youtubeVideoId.isNotEmpty) {
      connect(videoId: _config.chatToSpeechConfiguration.youtubeVideoId);
    } else {
      disconnect();
    }
  }

  void connect({required String videoId}) async {
    if (_isConnected) return;
    final extractedVideoId = videoId.youtubeVideoId;

    if (extractedVideoId == null) return;

    _isConnected = true;
    _statusSubject.add(SourceStatus.active);

    // Get the initial continuation token, API key, and context
    await _getInitialData(extractedVideoId);

    if (_continuation == null || _apiKey == null || _context == null) {
      _statusSubject.add(SourceStatus.inactive);
      disconnect();
      return;
    }

    // Start fetching messages
    _fetchLiveChatMessages();
  }

  Future<void> _getInitialData(String extractedVideoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$extractedVideoId');

    final response = await http.get(url, headers: {
      'User-Agent': 'Mozilla/5.0',
    });

    if (response.statusCode == 200) {
      final body = response.body;

      // Extract API key and context
      _apiKey = _extractApiKey(body);
      _context = _extractContext(body);

      // Parse the initial data
      final initialData = _extractInitialData(body);

      if (initialData != null) {
        _continuation = _extractContinuation(initialData);
      } else {
        _statusSubject.add(SourceStatus.inactive);
        disconnect();
      }
    } else {
      _statusSubject.add(SourceStatus.inactive);
      disconnect();
    }
  }

  dynamic _extractInitialData(String html) {
    final regex =
        RegExp(r'ytInitialData\s*=\s*(\{.*?\});<\/script>', dotAll: true);
    final match = regex.firstMatch(html);

    if (match != null) {
      final jsonData = match.group(1);
      if (jsonData != null) {
        return jsonDecode(jsonData);
      }
    }

    return null;
  }

  String? _extractApiKey(String html) {
    final regex = RegExp(r'"INNERTUBE_API_KEY":"(.*?)"');
    final match = regex.firstMatch(html);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  Map<String, dynamic>? _extractContext(String html) {
    final regex = RegExp(
        r'"INNERTUBE_CONTEXT":({.*?}),"INNERTUBE_CONTEXT_CLIENT_NAME"',
        dotAll: true);
    final match = regex.firstMatch(html);
    if (match != null) {
      final contextJson = match.group(1);
      if (contextJson != null) {
        return jsonDecode(contextJson);
      }
    }
    return null;
  }

  String? _extractContinuation(dynamic initialData) {
    try {
      final continuations = initialData['contents']['twoColumnWatchNextResults']
              ['conversationBar']['liveChatRenderer']['continuations']
          as List<dynamic>;

      for (var continuation in continuations) {
        if (continuation['reloadContinuationData'] != null) {
          return continuation['reloadContinuationData']['continuation'];
        } else if (continuation['invalidationContinuationData'] != null) {
          return continuation['invalidationContinuationData']['continuation'];
        } else if (continuation['timedContinuationData'] != null) {
          return continuation['timedContinuationData']['continuation'];
        }
      }
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  void _fetchLiveChatMessages() async {
    if (!_isConnected) return;

    if (_continuation == null || _apiKey == null || _context == null) {
      _statusSubject.add(SourceStatus.inactive);
      disconnect();
      return;
    }

    final url = Uri.parse(
        'https://www.youtube.com/youtubei/v1/live_chat/get_live_chat?key=$_apiKey');

    var requestBody = {
      'context': _context,
      'continuation': _continuation,
    };

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
        body: jsonEncode(requestBody));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);

      // Extract messages
      if (data['continuationContents'] != null &&
          data['continuationContents']['liveChatContinuation'] != null) {
        final liveChatContinuation =
            data['continuationContents']['liveChatContinuation'];

        // Process actions
        final actions = liveChatContinuation['actions'] as List<dynamic>? ?? [];

        for (var action in actions) {
          if (action['addChatItemAction'] != null) {
            final item = action['addChatItemAction']['item'];
            if (item['liveChatTextMessageRenderer'] != null) {
              final messageRenderer = item['liveChatTextMessageRenderer'];
              final message = _parseChatMessage(messageRenderer);
              if (message != null) {
                _messageSubject.add(message);
              }
            }
          }
        }

        // Get next continuation token and timeout
        final continuations =
            liveChatContinuation['continuations'] as List<dynamic>?;

        if (continuations != null && continuations.isNotEmpty) {
          var continuationData = continuations[0];

          int timeoutMs = 5000; // Default to 5 seconds

          if (continuationData['invalidationContinuationData'] != null) {
            _continuation = continuationData['invalidationContinuationData']
                ['continuation'];
            timeoutMs = continuationData['invalidationContinuationData']
                    ['timeoutMs'] ??
                timeoutMs;
          } else if (continuationData['timedContinuationData'] != null) {
            _continuation =
                continuationData['timedContinuationData']['continuation'];
            timeoutMs = continuationData['timedContinuationData']
                    ['timeoutMs'] ??
                timeoutMs;
          } else if (continuationData['reloadContinuationData'] != null) {
            _continuation =
                continuationData['reloadContinuationData']['continuation'];
            // timeoutMs remains default
          } else {
            // Unknown continuation data
            _statusSubject.add(SourceStatus.inactive);
            disconnect();
            return;
          }

          // Schedule the next fetch
          Future.delayed(Duration(milliseconds: timeoutMs), () {
            _fetchLiveChatMessages();
          });
        } else {
          // No continuations found
          _statusSubject.add(SourceStatus.inactive);
          disconnect();
        }
      } else {
        // No liveChatContinuation found
        _statusSubject.add(SourceStatus.inactive);
        disconnect();
      }
    } else {
      _statusSubject.add(SourceStatus.inactive);
      disconnect();
    }
  }

  Message? _parseChatMessage(dynamic renderer) {
    try {
      final authorName = renderer['authorName']['simpleText'];
      final authorExternalChannelId =
          renderer['authorExternalChannelId'] is String
              ? renderer['authorExternalChannelId']
              : '';
      final messageRuns = renderer['message']['runs'] as List<dynamic>;

      String rawMessage = '';
      for (var run in messageRuns) {
        if (run['text'] != null) {
          rawMessage += run['text'];
        } else if (run['emoji'] != null) {
          final emojiShortcuts = run['emoji']['shortcuts'] as List<dynamic>?;
          if (emojiShortcuts != null && emojiShortcuts.isNotEmpty) {
            rawMessage += emojiShortcuts.first;
          } else {
            rawMessage += run['emoji']['searchTerms'][0];
          }
        }
      }

      return streamkit.ChatMessage(
        id: renderer['id'],
        username: authorName,
        userId: authorExternalChannelId,
        suggestedSpeechMessage: rawMessage,
        rawMessage: rawMessage,
        emotePositions: [], // Add emote positions if needed
        emoteList: [], // Add emote list if needed
      );
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  void disconnect() {
    _isConnected = false;
    _statusSubject.add(SourceStatus.inactive);
  }
}
