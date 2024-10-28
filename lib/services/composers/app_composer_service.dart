import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/models/messages/prepared_message.dart';
import 'package:streamkit_tts/services/composers/composer_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/services/outputs/output_service.dart';
import 'package:streamkit_tts/services/sources/source_service.dart';

class QueueItem {
  final Message message;
  PreparedMessage? preparedMessage;

  QueueItem({
    required this.message,
    this.preparedMessage,
  });
}

class AppComposerService implements ComposerService {
  final SourceService _sourceService;
  final OutputService _outputService;
  final List<Middleware> _middlewares;
  final Config _config;

  final List<QueueItem> _messageQueue = [];

  final _isEnabled = PublishSubject<bool>();
  final _errorMessage = PublishSubject<String>();

  final _maxMessageQueue = 10;
  final _maxMessagePrepareTime = const Duration(seconds: 10);

  bool _isPlayingMessage = false;

  AppComposerService({
    required config,
    required sourceService,
    required middlewares,
    required outputService,
  })  : _config = config,
        _sourceService = sourceService,
        _middlewares = middlewares,
        _outputService = outputService {
    _sourceService.getMessageStream().listen(_onMessage);
    _config.addListener(_onConfigChanged);

    _onConfigChanged();

    getStatusStream()
        .where((status) => status == ComposerStatus.loading)
        .listen(_watchForInfiniteLoading);
  }

  void _onConfigChanged() {
    _isEnabled.add(_config.chatToSpeechConfiguration.enabled);
    if (!_config.chatToSpeechConfiguration.enabled) {
      _messageQueue
          .map((queueItem) => queueItem.preparedMessage)
          .nonNulls
          .forEach((preparedMessage) {
        _outputService.cancelPreparedMessage(preparedMessage);
      });

      _messageQueue.clear();
    }
  }

  void _watchForInfiniteLoading(_) async {
    await getStatusStream()
        .distinctUnique()
        .firstWhere((status) => status != ComposerStatus.loading)
        .timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _errorMessage.add(
            "Failed to connect to channel. Please check your internet connection or if you have entered the correct channel name.");
        _config.setEnabled(false);

        // When loading happens longer than 5 seconds, disable everything.
        return ComposerStatus.inactive;
      },
    );
  }

  @override
  Stream<ComposerStatus> getStatusStream() {
    return Rx.combineLatest2(
      _sourceService.getStatusStream().startWith(SourceStatus.inactive),
      _isEnabled.startWith(_config.chatToSpeechConfiguration.enabled),
      (sourceStatus, isEnabled) {
        if (isEnabled) {
          return sourceStatus == SourceStatus.inactive
              ? ComposerStatus.loading
              : ComposerStatus.active;
        } else {
          return sourceStatus == SourceStatus.inactive
              ? ComposerStatus.inactive
              : ComposerStatus.active;
        }
      },
    );
  }

  @override
  Stream<String> getErrorStream() {
    return _errorMessage.stream;
  }

  void _onMessage(Message message) async {
    Message? processedMessage = message;

    for (final middleware in _middlewares) {
      if (processedMessage == null) break;
      if (processedMessage.isSuggestedSpeechMessageFinalized) break;
      processedMessage = await middleware.process(processedMessage);
    }

    if (processedMessage == null) return;

    final queueItem = QueueItem(message: processedMessage);

    _outputService
        .prepareMessage(queueItem.message)
        .timeout(_maxMessagePrepareTime)
        .then((preparedMessage) {
      if (!_messageQueue.contains(queueItem)) {
        // Message no longer in queue
        _outputService.cancelPreparedMessage(preparedMessage);
        return;
      }

      queueItem.preparedMessage = preparedMessage;
      _playNextMessage();
    }, onError: (e) {
      print(e);
      _messageQueue.remove(queueItem);
    });

    _messageQueue.add(queueItem);

    while (_messageQueue.length > _maxMessageQueue) {
      final preparedMessage = _messageQueue.removeAt(0).preparedMessage;
      if (preparedMessage != null) {
        _outputService.cancelPreparedMessage(preparedMessage);
      }
    }
  }

  void _playNextMessage() async {
    if (_isPlayingMessage) return;
    _isPlayingMessage = true;

    if (_messageQueue.isEmpty) {
      _isPlayingMessage = false;
      return;
    }

    final queueItem = _messageQueue.first;
    final preparedMessage = queueItem.preparedMessage;
    if (preparedMessage == null) {
      _isPlayingMessage = false;
      return;
    }

    _messageQueue.remove(queueItem);

    try {
      await _outputService.playMessage(preparedMessage);
    } catch (_) {}

    _isPlayingMessage = false;
    _playNextMessage();
  }
}
