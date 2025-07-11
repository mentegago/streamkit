import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/messages/message.dart';

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
    required super.userId,
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
    String? userId,
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
      userId: userId ?? this.userId,
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
