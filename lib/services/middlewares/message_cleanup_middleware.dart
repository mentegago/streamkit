import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';

class MessageCleanupMiddleware implements Middleware {
  final Config _config;

  MessageCleanupMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;

    var suggestedSpeechMessage = message.suggestedSpeechMessage
        .replaceAll(
          RegExp(r'~|-|_'),
          " ",
        )
        .trim();

    if (!_config.chatToSpeechConfiguration.disableAKeongFilter) {
      if (message.language == Language.indonesian) {
        suggestedSpeechMessage =
            _replaceAtSymbol(suggestedSpeechMessage, withText: 'et');
      } else if (message.language == Language.japanese) {
        suggestedSpeechMessage =
            _replaceAtSymbol(suggestedSpeechMessage, withText: 'アット');
      }
    }

    return message.copyWith(
      suggestedSpeechMessage: suggestedSpeechMessage,
    );
  }

  String _replaceAtSymbol(String input, {required String withText}) {
    // Regular expression to match one or more "@"s that are either
    // at the start/end of the string or surrounded by whitespace.
    final pattern = RegExp(r'(?<=^|\s)(@+)(?=\s|$)');

    return input.replaceAllMapped(
      pattern,
      (match) {
        final atSequence = match.group(1)!;
        final count = atSequence.length;
        return List.filled(count, withText).join(' ');
      },
    );
  }
}
