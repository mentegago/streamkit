import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class ReadUsernameMiddleware implements Middleware {
  final Config _config;

  ReadUsernameMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (_config.chatToSpeechConfiguration.readUsername) {
      return message.copyWith(
        suggestedSpeechMessage:
            "${message.username}, ${message.suggestedSpeechMessage}",
      );
    }

    return message;
  }
}
