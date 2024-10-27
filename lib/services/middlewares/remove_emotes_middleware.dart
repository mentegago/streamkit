import 'dart:math';

import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/chat_message.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:collection/collection.dart';
import 'package:streamkit_tts/utils/clean_message_util.dart';

class RemoveEmotesMiddleware implements Middleware {
  final Config _config;

  RemoveEmotesMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (!_config.chatToSpeechConfiguration.ignoreEmotes) return message;

    final emotelessMessage = message.emotePositions
        .sorted((a, b) => b.startPosition - a.startPosition)
        .fold(
      message.suggestedSpeechMessage,
      (message, emotePosition) {
        if (emotePosition.startPosition > message.length) return message;

        return message.replaceRange(
          emotePosition.startPosition,
          min(emotePosition.endPosition + 1, message.length),
          '',
        );
      },
    ).replaceWords(message.emoteList);

    return message.copyWith(suggestedSpeechMessage: emotelessMessage);
  }
}
