import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class SkipExclamationMiddleware implements Middleware {
  final Config _config;

  SkipExclamationMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (_config.chatToSpeechConfiguration.ignoreExclamationMark &&
        message.suggestedSpeechMessage.startsWith("!")) {
      return null;
    }

    return message;
  }
}
