import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';
import 'package:streamkit_tts/utils/misc_tts_util.dart';

class PachifyMiddleware implements Middleware {
  final MiscTts _miscTtsUtil;
  final ExternalConfig _externalConfig;

  PachifyMiddleware({
    required MiscTts miscTtsUtil,
    required externalConfig,
  })  : _miscTtsUtil = miscTtsUtil,
        _externalConfig = externalConfig;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    var messageText = _miscTtsUtil.pachify(
      message.suggestedSpeechMessage,
      userId: message.userId,
      panciList: _externalConfig.panciList,
    );
    messageText = _miscTtsUtil.warafy(messageText);

    return message.copyWith(
      suggestedSpeechMessage: messageText,
    );
  }
}
