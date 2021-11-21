// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configurations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configurations _$ConfigurationsFromJson(Map<String, dynamic> json) =>
    Configurations(
      chatToSpeech: ChatToSpeechConfiguration.fromJson(
          json['chatToSpeech'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConfigurationsToJson(Configurations instance) =>
    <String, dynamic>{
      'chatToSpeech': instance.chatToSpeech,
    };
