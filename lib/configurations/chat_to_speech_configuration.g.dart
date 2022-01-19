// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_to_speech_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatToSpeechConfiguration _$ChatToSpeechConfigurationFromJson(
        Map<String, dynamic> json) =>
    ChatToSpeechConfiguration(
      channels:
          (json['channels'] as List<dynamic>).map((e) => e as String).toList(),
      readUsername: json['readUsername'] as bool,
      ignoreExclamationMark: json['ignoreExclamationMark'] as bool,
      languages: (json['languages'] as List<dynamic>)
          .map((e) => $enumDecode(_$LanguageEnumMap, e))
          .toSet(),
      enabled: json['enabled'] as bool,
      volume: (json['volume'] as num?)?.toDouble(),
      readBsr: json['readBsr'] as bool?,
    );

Map<String, dynamic> _$ChatToSpeechConfigurationToJson(
        ChatToSpeechConfiguration instance) =>
    <String, dynamic>{
      'channels': instance.channels,
      'readUsername': instance.readUsername,
      'ignoreExclamationMark': instance.ignoreExclamationMark,
      'languages': instance.languages.map((e) => _$LanguageEnumMap[e]).toList(),
      'enabled': instance.enabled,
      'volume': instance.volume,
      'readBsr': instance.readBsr,
    };

const _$LanguageEnumMap = {
  Language.english: 'english',
  Language.indonesian: 'indonesian',
  Language.japanese: 'japanese',
};
