import 'dart:convert';

import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';

class ChatToSpeechConfiguration {
  final Set<String> channels;
  final bool readUsername;
  final bool readUsernameOnEmptyMessage;
  final bool ignoreExclamationMark;
  final bool ignoreEmotes;
  final Set<Language> languages;
  final bool enabled;
  final double volume;
  final bool readBsr;
  final bool readBsrSafely;
  final TtsSource ttsSource;
  final Set<String> filteredUsernames;
  final bool isWhitelistingFilter;
  final bool ignoreEmptyMessage;
  final bool ignoreUrls;
  final bool disableAKeongFilter;

  ChatToSpeechConfiguration({
    required this.channels,
    required this.readUsername,
    required this.readUsernameOnEmptyMessage,
    required this.ignoreExclamationMark,
    required this.ignoreEmotes,
    required this.languages,
    required this.enabled,
    required this.volume,
    required this.readBsr,
    required this.readBsrSafely,
    required this.ttsSource,
    required this.filteredUsernames,
    required this.isWhitelistingFilter,
    required this.ignoreEmptyMessage,
    required this.ignoreUrls,
    required this.disableAKeongFilter,
  });

  ChatToSpeechConfiguration copyWith({
    Set<String>? channels,
    bool? readUsername,
    bool? readUsernameOnEmptyMessage,
    bool? ignoreExclamationMark,
    bool? ignoreEmotes,
    Set<Language>? languages,
    bool? enabled,
    double? volume,
    bool? readBsr,
    bool? readBsrSafely,
    TtsSource? ttsSource,
    Set<String>? filteredUsernames,
    bool? isWhitelistingFilter,
    bool? ignoreEmptyMessage,
    bool? ignoreUrls,
    bool? disableAKeongFilter,
  }) {
    return ChatToSpeechConfiguration(
      channels: channels ?? this.channels,
      readUsername: readUsername ?? this.readUsername,
      readUsernameOnEmptyMessage:
          readUsernameOnEmptyMessage ?? this.readUsernameOnEmptyMessage,
      ignoreExclamationMark:
          ignoreExclamationMark ?? this.ignoreExclamationMark,
      ignoreEmotes: ignoreEmotes ?? this.ignoreEmotes,
      languages: languages ?? this.languages,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      readBsr: readBsr ?? this.readBsr,
      readBsrSafely: readBsrSafely ?? this.readBsrSafely,
      ttsSource: ttsSource ?? this.ttsSource,
      filteredUsernames: filteredUsernames ?? this.filteredUsernames,
      isWhitelistingFilter: isWhitelistingFilter ?? this.isWhitelistingFilter,
      ignoreEmptyMessage: ignoreEmptyMessage ?? this.ignoreEmptyMessage,
      ignoreUrls: ignoreUrls ?? this.ignoreUrls,
      disableAKeongFilter: disableAKeongFilter ?? this.disableAKeongFilter,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'channels': channels.toList()});
    result.addAll({'readUsername': readUsername});
    result.addAll({'readUsernameOnEmptyMessage': readUsernameOnEmptyMessage});
    result.addAll({'ignoreExclamationMark': ignoreExclamationMark});
    result.addAll({'ignoreEmotes': ignoreEmotes});
    result.addAll({'languages': languages.map((x) => x.google).toList()});
    result.addAll({'enabled': enabled});
    result.addAll({'volume': volume});
    result.addAll({'readBsr': readBsr});
    result.addAll({'readBsrSafely': readBsrSafely});
    result.addAll({'ttsSource': ttsSource.string});
    result.addAll({'filteredUsernames': filteredUsernames.toList()});
    result.addAll({'isWhitelistingFilter': isWhitelistingFilter});
    result.addAll({'ignoreEmptyMessage': ignoreEmptyMessage});
    result.addAll({'ignoreUrls': ignoreUrls});
    result.addAll({'disableAKeongFilter': disableAKeongFilter});

    return result;
  }

  factory ChatToSpeechConfiguration.fromMap(Map<String, dynamic> map) {
    return ChatToSpeechConfiguration(
      channels: Set<String>.from(map['channels']),
      readUsername: map['readUsername'] ?? true,
      readUsernameOnEmptyMessage: map['readUsernameOnEmptyMessage'] ?? false,
      ignoreExclamationMark: map['ignoreExclamationMark'] ?? true,
      ignoreEmotes: map['ignoreEmotes'] ?? true,
      languages: Set<Language>.from(
          map['languages']?.map((x) => LanguageParser.fromGoogle(x)) ??
              [Language.english, Language.indonesian, Language.japanese]),
      enabled: map['enabled'] ?? false,
      volume: map['volume']?.toDouble() ?? 100.0,
      readBsr: map['readBsr'] ?? false,
      readBsrSafely: map['readBsrSafely'] ?? false,
      ttsSource: TtsSourceParser.fromString(map['ttsSource'] ?? '') ??
          TtsSource.google,
      filteredUsernames: Set<String>.from(map['filteredUsernames'] ?? []),
      isWhitelistingFilter: map['isWhitelistingFilter'] ?? false,
      ignoreEmptyMessage: map['ignoreEmptyMessage'] ?? true,
      ignoreUrls: map['ignoreUrls'] ?? true,
      disableAKeongFilter: map['disableAKeongFilter'] ?? false,
    );
  }

  factory ChatToSpeechConfiguration.defaultConfig() =>
      ChatToSpeechConfiguration(
        channels: {},
        enabled: false,
        ignoreExclamationMark: true,
        languages: {Language.english, Language.indonesian, Language.japanese},
        readBsr: false,
        readUsername: true,
        readUsernameOnEmptyMessage: false,
        volume: 100.0,
        ignoreEmotes: true,
        readBsrSafely: false,
        ttsSource: TtsSource.google,
        filteredUsernames: {},
        isWhitelistingFilter: false,
        ignoreEmptyMessage: true,
        ignoreUrls: true,
        disableAKeongFilter: false,
      );

  String toJson() => _prettyJson(toMap());

  factory ChatToSpeechConfiguration.fromJson(String source) =>
      ChatToSpeechConfiguration.fromMap(json.decode(source));

  String _prettyJson(dynamic json) {
    var spaces = ' ' * 4;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }
}
