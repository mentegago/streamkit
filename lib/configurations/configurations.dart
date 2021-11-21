import 'package:json_annotation/json_annotation.dart';
import 'package:streamkit/configurations/chat_to_speech_configuration.dart';
import 'package:streamkit/modules/enums/language.dart';

part 'configurations.g.dart';

@JsonSerializable()
class Configurations {
  final ChatToSpeechConfiguration chatToSpeech;

  Configurations({required this.chatToSpeech});
  factory Configurations.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationsFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigurationsToJson(this);

  factory Configurations.defaultConfiguration() => Configurations(
        chatToSpeech: ChatToSpeechConfiguration(
            channels: [],
            ignoreExclamationMark: true,
            languages: {
              Language.english,
              Language.indonesian,
              Language.japanese
            },
            readUsername: true,
            enabled: false),
      );

  Configurations copyWith({
    ChatToSpeechConfiguration? chatToSpeech,
  }) {
    return Configurations(
      chatToSpeech: chatToSpeech ?? this.chatToSpeech,
    );
  }
}
