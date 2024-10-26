import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/outputs/GoogleTtsOutput.dart';
import 'package:streamkit_tts/services/sources/twitch_chat_source.dart';

import 'interfaces/text_to_speech_service.dart';

enum ComposerStatus { inactive, loading, active }

abstract class ComposerService {
  Stream<ComposerStatus> getStatusStream();
}

class AppComposerService implements ComposerService {
  final SourceService _sourceService;
  final OutputService _outputService = GoogleTtsOutput();
  final Config _config;

  ChatToSpeechConfiguration? _previousConfig;

  List<Message> _queuedMessages = [];
  List<PreparedMessage> _queuedPreparedMessages = [];

  AppComposerService({
    required config,
  })  : _config = config,
        _sourceService = TwitchChatSource(config: config) {
    _sourceService.getMessageStream().listen(_onMessage);
  }

  @override
  Stream<ComposerStatus> getStatusStream() {
    return _sourceService.getStatusStream().map((status) {
      if (_config.chatToSpeechConfiguration.enabled) {
        return status == SourceStatus.inactive
            ? ComposerStatus.loading
            : ComposerStatus.active;
      } else {
        return status == SourceStatus.inactive
            ? ComposerStatus.inactive
            : ComposerStatus.active;
      }
    });
  }

  void _onMessage(Message message) {
    _queuedMessages.add(message);

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
