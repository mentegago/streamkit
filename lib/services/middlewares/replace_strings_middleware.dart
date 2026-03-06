import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/clean_message_util.dart';

class ReplaceStringsMiddleware implements Middleware {
  final Config _config;

  ReplaceStringsMiddleware({required Config config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    final rules = _config.chatToSpeechConfiguration.replaceStringRules;
    if (rules.isEmpty) return message;

    String result = message.suggestedSpeechMessage;

    for (final rule in rules) {
      result = result.replaceStrings(
        [rule.from],
        replacement: rule.to,
        wholeWord: rule.wholeWord,
        caseInsensitive: !rule.caseSensitive,
      );
    }

    return message.copyWith(suggestedSpeechMessage: result);
  }
}
