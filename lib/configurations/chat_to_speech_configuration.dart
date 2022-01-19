import 'package:streamkit/modules/enums/language.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_to_speech_configuration.g.dart';

@JsonSerializable()
class ChatToSpeechConfiguration {
  final List<String> channels;
  final bool readUsername;
  final bool ignoreExclamationMark;
  final Set<Language> languages;
  final bool enabled;
  final double? volume;

  factory ChatToSpeechConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ChatToSpeechConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToSpeechConfigurationToJson(this);

  ChatToSpeechConfiguration({
    required this.channels,
    required this.readUsername,
    required this.ignoreExclamationMark,
    required this.languages,
    required this.enabled,
    this.volume,
  });
}
