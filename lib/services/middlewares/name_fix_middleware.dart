import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/clean_message_util.dart';
import 'package:streamkit_tts/utils/external_config_util.dart';

class NameFixMiddleware implements Middleware {
  final ExternalConfig _externalConfig;

  NameFixMiddleware({
    required externalConfig,
  }) : _externalConfig = externalConfig;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    final language = message.language;
    if (language == null) return message;

    final updatedMessage = _externalConfig.nameFixConfig.names
        .map((name) {
          switch (language) {
            case Language.english:
              return (name.original, name.en);

            case Language.french:
              return (name.original, name.fr);

            case Language.indonesian:
              return (name.original, name.id);

            case Language.japanese:
              return (name.original, name.jp);
          }
        })
        .where((name) => name.$2 != null)
        .fold(
          message.suggestedSpeechMessage,
          (message, name) {
            final replacedMessaged = message.replaceWords(
              [name.$1],
              replacement: name.$2 ?? '',
              replaceEndOfSentenceWord: true,
            );

            return replacedMessaged;
          },
        );

    return message.copyWith(suggestedSpeechMessage: updatedMessage);
  }
}
