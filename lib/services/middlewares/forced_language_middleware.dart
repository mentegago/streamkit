import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class ForcedLanguageMiddleware implements Middleware {
  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    final splitMessage = message.suggestedSpeechMessage.trim().split(' ');
    if (splitMessage.length < 2) return message;

    var forcedLanguage = LanguageParser.fromForceCode(splitMessage.first);

    return message.copyWith(
      language: forcedLanguage,
      suggestedSpeechMessage:
          forcedLanguage != null ? splitMessage.sublist(1).join(' ') : null,
    );
  }
}
