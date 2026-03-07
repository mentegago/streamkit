import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/clean_message_util.dart';

class WordFilterMiddleware implements Middleware {
  final Config _config;

  WordFilterMiddleware({required Config config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    final rules = _config.chatToSpeechConfiguration.wordFilterRules;
    if (rules.isEmpty) return message;

    final text = message.suggestedSpeechMessage;

    final matchesAny = rules.any((rule) => text.containsString(
          rule.word,
          wholeWord: rule.wholeWord,
          caseInsensitive: !rule.caseSensitive,
        ));

    final isWhitelist = _config.chatToSpeechConfiguration.isWordlistWhitelist;

    if (isWhitelist) {
      return matchesAny ? message : null;
    } else {
      return matchesAny ? null : message;
    }
  }
}
