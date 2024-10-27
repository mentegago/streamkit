import 'package:streamkit_tts/models/enums/languages_enum.dart';

abstract class Message {
  final String id;
  final String username;
  final String suggestedSpeechMessage;
  final Language? language;
  final bool isSuggestedSpeechMessageFinalized;

  Message({
    required this.id,
    required this.username,
    required this.suggestedSpeechMessage,
    this.language,
    this.isSuggestedSpeechMessageFinalized = false,
  });

  Message copyWith({
    String? username,
    String? suggestedSpeechMessage,
    Language? language,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
