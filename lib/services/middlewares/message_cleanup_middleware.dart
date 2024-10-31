import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class MessageCleanupMiddleware implements Middleware {
  MessageCleanupMiddleware();

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    return message.copyWith(
      suggestedSpeechMessage: message.suggestedSpeechMessage
          .replaceAll(
            RegExp(r'~|-|_'),
            " ",
          )
          .trim(),
    );
  }
}
