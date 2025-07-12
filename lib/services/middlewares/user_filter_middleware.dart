import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class UserFilterMiddleware implements Middleware {
  final Config _config;

  UserFilterMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (_config.chatToSpeechConfiguration.isWhitelistingFilter) {
      if (_config.chatToSpeechConfiguration.filteredUserIds
          .contains(message.userId)) return message;
    } else {
      if (!_config.chatToSpeechConfiguration.filteredUserIds
          .contains(message.userId)) return message;
    }

    return null;
  }
}
