import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class VtuberNameFilterMiddleware implements Middleware {
  final Config _config;

  VtuberNameFilterMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (!_config.chatToSpeechConfiguration.ignoreVtuberGroupName) {
      return message;
    }

    final username = message.username
        .replaceAll(RegExp(r' ch\..*', caseSensitive: false), "")
        .replaceAll(RegExp(r'\s*【[^】]*】'), "")
        .replaceAll(RegExp(r'\s*[[^\]]*]'), "")
        .replaceAll(RegExp(r'\s*「[^」]*」'), "");

    return message.copyWith(
      username: username,
    );
  }
}
