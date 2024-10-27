import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/clean_message_util.dart';

class RemoveUrlsMiddleware implements Middleware {
  final Config _config;

  RemoveUrlsMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (!_config.chatToSpeechConfiguration.ignoreUrls) return message;

    return message.copyWith(
      suggestedSpeechMessage: message.suggestedSpeechMessage.removeUrls(),
    );
  }
}
