import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/language_detection_util.dart';

class LanguageMiddleware implements Middleware {
  final Config _config;
  final _languageDetection = LanguageDetection();

  LanguageMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (message.language != null) return message;

    final language = _languageDetection.getLanguage(
      message.suggestedSpeechMessage,
      whitelistedLanguages: _config.chatToSpeechConfiguration.languages,
    );

    return message.copyWith(language: language);
  }
}
