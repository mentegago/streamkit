import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:streamkit_tts/models/enums/languages_enum.dart';

class ChatToSpeechConfiguration {
  final Set<String> channels;
  final bool readUsername;
  final bool ignoreExclamationMark;
  final bool ignoreEmotes;
  final Set<Language> languages;
  final bool enabled;
  final double volume;
  final bool readBsr;

  ChatToSpeechConfiguration({
    required this.channels,
    required this.readUsername,
    required this.ignoreExclamationMark,
    required this.ignoreEmotes,
    required this.languages,
    required this.enabled,
    required this.volume,
    required this.readBsr,
  });

  ChatToSpeechConfiguration copyWith({
    Set<String>? channels,
    bool? readUsername,
    bool? ignoreExclamationMark,
    bool? ignoreEmotes,
    Set<Language>? languages,
    bool? enabled,
    double? volume,
    bool? readBsr,
  }) {
    return ChatToSpeechConfiguration(
      channels: channels ?? this.channels,
      readUsername: readUsername ?? this.readUsername,
      ignoreExclamationMark:
          ignoreExclamationMark ?? this.ignoreExclamationMark,
      ignoreEmotes: ignoreEmotes ?? this.ignoreEmotes,
      languages: languages ?? this.languages,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      readBsr: readBsr ?? this.readBsr,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'channels': channels.toList()});
    result.addAll({'readUsername': readUsername});
    result.addAll({'ignoreExclamationMark': ignoreExclamationMark});
    result.addAll({'ignoreEmotes': ignoreEmotes});
    result.addAll({'languages': languages.map((x) => x.google).toList()});
    result.addAll({'enabled': enabled});
    result.addAll({'volume': volume});
    result.addAll({'readBsr': readBsr});

    return result;
  }

  factory ChatToSpeechConfiguration.fromMap(Map<String, dynamic> map) {
    return ChatToSpeechConfiguration(
      channels: Set<String>.from(map['channels']),
      readUsername: map['readUsername'] ?? false,
      ignoreExclamationMark: map['ignoreExclamationMark'] ?? false,
      ignoreEmotes: map['ignoreEmotes'] ?? false,
      languages: Set<Language>.from(
          map['languages']?.map((x) => LanguageParser.fromGoogle(x))),
      enabled: map['enabled'] ?? false,
      volume: map['volume']?.toDouble() ?? 0.0,
      readBsr: map['readBsr'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatToSpeechConfiguration.fromJson(String source) =>
      ChatToSpeechConfiguration.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatToSpeechConfiguration(channels: $channels, readUsername: $readUsername, ignoreExclamationMark: $ignoreExclamationMark, ignoreEmotes: $ignoreEmotes, languages: $languages, enabled: $enabled, volume: $volume, readBsr: $readBsr)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatToSpeechConfiguration &&
        setEquals(other.channels, channels) &&
        other.readUsername == readUsername &&
        other.ignoreExclamationMark == ignoreExclamationMark &&
        other.ignoreEmotes == ignoreEmotes &&
        setEquals(other.languages, languages) &&
        other.enabled == enabled &&
        other.volume == volume &&
        other.readBsr == readBsr;
  }

  @override
  int get hashCode {
    return channels.hashCode ^
        readUsername.hashCode ^
        ignoreExclamationMark.hashCode ^
        ignoreEmotes.hashCode ^
        languages.hashCode ^
        enabled.hashCode ^
        volume.hashCode ^
        readBsr.hashCode;
  }
}
