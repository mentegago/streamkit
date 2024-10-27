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

class EmotePosition {
  final int startPosition;
  final int endPosition;

  EmotePosition({
    required this.startPosition,
    required this.endPosition,
  });
}

class ChatMessage extends Message {
  final String rawMessage;
  final List<EmotePosition> emotePositions;
  final List<String> emoteList;

  ChatMessage({
    required super.id,
    required super.username,
    required super.suggestedSpeechMessage,
    super.language,
    super.isSuggestedSpeechMessageFinalized = false,
    required this.rawMessage,
    this.emotePositions = const [],
    this.emoteList = const [],
  });

  @override
  ChatMessage copyWith({
    String? username,
    String? suggestedSpeechMessage,
    Language? language,
    bool? isSuggestedSpeechMessageFinalized,
    String? rawMessage,
    List<EmotePosition>? emotePositions,
    List<String>? emoteList,
  }) {
    return ChatMessage(
      id: id,
      username: username ?? this.username,
      suggestedSpeechMessage:
          suggestedSpeechMessage ?? this.suggestedSpeechMessage,
      language: language ?? this.language,
      isSuggestedSpeechMessageFinalized: isSuggestedSpeechMessageFinalized ??
          this.isSuggestedSpeechMessageFinalized,
      rawMessage: rawMessage ?? this.rawMessage,
      emotePositions: emotePositions ?? this.emotePositions,
      emoteList: emoteList ?? this.emoteList,
    );
  }
}
