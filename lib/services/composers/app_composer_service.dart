import 'package:rxdart/rxdart.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/composers/composer_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/services/outputs/google_tts_output.dart';
import 'package:streamkit_tts/services/outputs/output_service.dart';
import 'package:streamkit_tts/services/sources/source_service.dart';
import 'package:streamkit_tts/services/sources/twitch_chat_source.dart';

import '../interfaces/text_to_speech_service.dart';

class AppComposerService implements ComposerService {
  final SourceService _sourceService;
  final OutputService _outputService;
  final List<Middleware> _middlewares;
  final Config _config;

  final List<Message> _queuedMessages = [];
  final List<PreparedMessage> _queuedPreparedMessages = [];

  final _isEnabled = PublishSubject<bool>();
  final _errorMessage = PublishSubject<String>();

  final int maxMessageQueue = 10;

  AppComposerService({
    required config,
    required middlewares,
  })  : _config = config,
        _sourceService = TwitchChatSource(config: config),
        _outputService = GoogleTtsOutput(config: config),
        _middlewares = middlewares {
    _sourceService.getMessageStream().listen(_onMessage);
    _config.addListener(_onConfigChanged);

    _onConfigChanged();

    getStatusStream()
        .where((status) => status == ComposerStatus.loading)
        .listen(_watchForInfiniteLoading);
  }

  void _onConfigChanged() {
    _isEnabled.add(_config.chatToSpeechConfiguration.enabled);
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

    _queuedMessages.add(processedMessage);

    if (_queuedMessages.length == 1) {
      // No message in queue prior to this.
      _prepareNextMessage();
    }
  }

  void _prepareNextMessage() async {
    final message = _queuedMessages.firstOrNull;
    if (message == null) {
      return;
    }

    try {
      final preparedMessage = await _outputService.prepareAudio(message);
      _queuedPreparedMessages.add(preparedMessage);

      while (_queuedPreparedMessages.length > maxMessageQueue) {
        final removedMessage = _queuedPreparedMessages.removeAt(0);
        _outputService.cancelAudio(removedMessage);
      }

      if (_queuedPreparedMessages.length == 1) {
        // No message in queue prior to this.
        _playNextMessage();
      }
    } catch (e) {
      print(e);
    }

    _queuedMessages.removeAt(0);
    _prepareNextMessage();
  }

  void _playNextMessage() async {
    final preparedMessage = _queuedPreparedMessages.firstOrNull;
    if (preparedMessage == null) {
      return;
    }

    try {
      await _outputService.playAudio(preparedMessage);
    } catch (e) {
      print(e);
    }

    _queuedPreparedMessages.removeAt(0);
    _playNextMessage();
  }
}
