import 'package:streamkit_tts/models/enums/languages_enum.dart';

abstract class TextToSpeechServiceProtocol {
  Future<PreparedMessage?> prepareSpeechForMessage(Message message);
  Future<void> removePreparedMessage(Message message);
  Future<void> playPreparedMessage(Message message);
}

class PreparedMessage {
  final Message message;
  final double? duration;

  PreparedMessage({
    required this.message,
    this.duration,
  });
}

abstract class Message {
  final String id;
  final String username;
  final String suggestedSpeechMessage;
  final Language language;

  Message({
    required this.id,
    required this.username,
    required this.suggestedSpeechMessage,
    required this.language,
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

class ChatMessage extends Message {
  final String message;

  ChatMessage({
    required String id,
    required String username,
    required String suggestedSpeechMessage,
    required Language language,
    required this.message,
  }) : super(
          id: id,
          username: username,
          suggestedSpeechMessage: suggestedSpeechMessage,
          language: language,
        );

  @override
  ChatMessage copyWith({
    String? username,
    String? suggestedSpeechMessage,
    String? message,
    Language? language,
  }) {
    return ChatMessage(
      id: id,
      username: username ?? this.username,
      suggestedSpeechMessage:
          suggestedSpeechMessage ?? this.suggestedSpeechMessage,
      message: message ?? this.message,
      language: language ?? this.language,
    );
  }
}
