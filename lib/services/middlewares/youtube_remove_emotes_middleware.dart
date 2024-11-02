import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class YouTubeRemoveEmotesMiddleware implements Middleware {
  final Config _config;

  YouTubeRemoveEmotesMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (!_config.chatToSpeechConfiguration.ignoreEmotes) return message;

    return message.copyWith(
      suggestedSpeechMessage: message.suggestedSpeechMessage.replaceAll(
        RegExp(r':[a-zA-Z0-9\_\-]+:'),
        '',
      ),
    );
  }
}
