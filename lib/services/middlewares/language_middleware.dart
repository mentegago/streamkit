import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/services/language_detection_service.dart';

class LanguageMiddleware implements Middleware {
  final Config _config;
  final LanguageDetectionService _languageDetectionService;

  LanguageMiddleware({
    required config,
    required languageDetectionService,
  })  : _config = config,
        _languageDetectionService = languageDetectionService;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (message.language != null) return message;

    final language = _languageDetectionService.getLanguage(
      message.suggestedSpeechMessage,
      whitelistedLanguages: _config.chatToSpeechConfiguration.languages,
    );

    return message.copyWith(language: language);
  }
}
