import 'dart:convert';

import 'package:streamkit_tts/flavor_config.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/app_theme_mode.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/models/replace_string_rule.dart';

class ChatToSpeechConfiguration {
  final Set<String> channels;
  final String youtubeVideoId;
  final bool readUsername;
  final bool ignoreExclamationMark;
  final bool ignoreEmotes;
  final bool ignoreBttvEmotes;
  final Set<Language> languages;
  final bool enabled;
  final double volume;
  final bool readBsr;
  final bool readBsrSafely;
  final TtsSource ttsSource;
  final Set<String> filteredUserIds;
  final bool isWhitelistingFilter;
  final bool ignoreEmptyMessage;
  final bool ignoreUrls;
  final bool ignoreVtuberGroupName;
  final bool disableAKeongFilter;
  final AppThemeMode themeMode;
  final List<ReplaceStringRule> replaceStringRules;

  ChatToSpeechConfiguration({
    required this.channels,
    required this.youtubeVideoId,
    required this.readUsername,
    required this.ignoreExclamationMark,
    required this.ignoreEmotes,
    required this.ignoreBttvEmotes,
    required this.languages,
    required this.enabled,
    required this.volume,
    required this.readBsr,
    required this.readBsrSafely,
    required this.ttsSource,
    required this.filteredUserIds,
    required this.isWhitelistingFilter,
    required this.ignoreEmptyMessage,
    required this.ignoreUrls,
    required this.ignoreVtuberGroupName,
    required this.disableAKeongFilter,
    required this.themeMode,
    required this.replaceStringRules,
  });

  ChatToSpeechConfiguration copyWith({
    Set<String>? channels,
    String? youtubeVideoId,
    bool? readUsername,
    bool? readUsernameOnEmptyMessage,
    bool? ignoreExclamationMark,
    bool? ignoreEmotes,
    bool? ignoreBttvEmotes,
    Set<Language>? languages,
    bool? enabled,
    double? volume,
    bool? readBsr,
    bool? readBsrSafely,
    TtsSource? ttsSource,
    Set<String>? filteredUserIds,
    bool? isWhitelistingFilter,
    bool? ignoreEmptyMessage,
    bool? ignoreUrls,
    bool? ignoreVtuberGroupName,
    bool? disableAKeongFilter,
    AppThemeMode? themeMode,
    List<ReplaceStringRule>? replaceStringRules,
  }) {
    return ChatToSpeechConfiguration(
      channels: channels ?? this.channels,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      readUsername: readUsername ?? this.readUsername,
      ignoreExclamationMark:
          ignoreExclamationMark ?? this.ignoreExclamationMark,
      ignoreEmotes: ignoreEmotes ?? this.ignoreEmotes,
      ignoreBttvEmotes: ignoreBttvEmotes ?? this.ignoreBttvEmotes,
      languages: languages ?? this.languages,
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      readBsr: readBsr ?? this.readBsr,
      readBsrSafely: readBsrSafely ?? this.readBsrSafely,
      ttsSource: ttsSource ?? this.ttsSource,
      filteredUserIds: filteredUserIds ?? this.filteredUserIds,
      isWhitelistingFilter: isWhitelistingFilter ?? this.isWhitelistingFilter,
      ignoreEmptyMessage: ignoreEmptyMessage ?? this.ignoreEmptyMessage,
      ignoreUrls: ignoreUrls ?? this.ignoreUrls,
      ignoreVtuberGroupName:
          ignoreVtuberGroupName ?? this.ignoreVtuberGroupName,
      disableAKeongFilter: disableAKeongFilter ?? this.disableAKeongFilter,
      themeMode: themeMode ?? this.themeMode,
      replaceStringRules: replaceStringRules ?? this.replaceStringRules,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'channels': channels.toList()});
    result.addAll({'youtubeVideoId': youtubeVideoId});
    result.addAll({'readUsername': readUsername});
    result.addAll({'ignoreExclamationMark': ignoreExclamationMark});
    result.addAll({'ignoreEmotes': ignoreEmotes});
    result.addAll({'ignoreBttvEmotes': ignoreBttvEmotes});
    result.addAll({'languages': languages.map((x) => x.google).toList()});
    result.addAll({'enabled': enabled});
    result.addAll({'volume': volume});
    result.addAll({'readBsr': readBsr});
    result.addAll({'readBsrSafely': readBsrSafely});
    result.addAll({'ttsSource': ttsSource.string});
    result.addAll({'filteredUsernames': filteredUserIds.toList()});
    result.addAll({'isWhitelistingFilter': isWhitelistingFilter});
    result.addAll({'ignoreEmptyMessage': ignoreEmptyMessage});
    result.addAll({'ignoreUrls': ignoreUrls});
    result.addAll({'ignoreVtuberGroupName': ignoreVtuberGroupName});
    result.addAll({'disableAKeongFilter': disableAKeongFilter});
    result.addAll({'themeMode': themeMode.name});
    result.addAll({'replaceStringRules': replaceStringRules.map((r) => r.toMap()).toList()});
    return result;
  }

  factory ChatToSpeechConfiguration.fromMap(Map<String, dynamic> map) {
    return ChatToSpeechConfiguration(
      channels: Set<String>.from(map['channels'] ?? []),
      youtubeVideoId: map["youtubeVideoId"] ?? "",
      readUsername: map['readUsername'] ?? true,
      ignoreExclamationMark: map['ignoreExclamationMark'] ?? true,
      ignoreEmotes: map['ignoreEmotes'] ?? true,
      ignoreBttvEmotes: map['ignoreBttvEmotes'] ?? true,
      languages: Set<Language>.from(
          map['languages']?.map((x) => LanguageParser.fromGoogle(x)) ??
              [Language.english, Language.indonesian, Language.japanese]),
      enabled: FlavorConfig.isYouTube
          ? false // For YouTube, always start disabled — video ID may be stale.
          : (map['enabled'] ?? false),
      volume: map['volume']?.toDouble() ?? 100.0,
      readBsr: map['readBsr'] ?? false,
      readBsrSafely: map['readBsrSafely'] ?? false,
      ttsSource: TtsSourceParser.fromString(map['ttsSource'] ?? '') ??
          TtsSource.google,
      filteredUserIds: Set<String>.from(map['filteredUsernames'] ?? []),
      isWhitelistingFilter: map['isWhitelistingFilter'] ?? false,
      ignoreEmptyMessage: map['ignoreEmptyMessage'] ?? true,
      ignoreUrls: map['ignoreUrls'] ?? true,
      ignoreVtuberGroupName: map['ignoreVtuberGroupName'] ?? true,
      disableAKeongFilter: map['disableAKeongFilter'] ?? false,
      themeMode: AppThemeMode.values.byName(map['themeMode'] ?? 'dark'),
      replaceStringRules: (map['replaceStringRules'] as List<dynamic>?)
              ?.map((e) => ReplaceStringRule.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory ChatToSpeechConfiguration.defaultConfig() =>
      ChatToSpeechConfiguration.fromMap({});

  String toJson() => _prettyJson(toMap());

  factory ChatToSpeechConfiguration.fromJson(String source) =>
      ChatToSpeechConfiguration.fromMap(json.decode(source));

  String _prettyJson(dynamic json) {
    var spaces = ' ' * 4;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }
}
