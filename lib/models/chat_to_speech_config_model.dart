import 'dart:convert';

import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';

class ChatToSpeechConfiguration {
  final Set<String> channels;
  final String youtubeVideoId;
  final bool readUsername;
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
  final bool ignoreVtuberGroupName;
  final bool disableAKeongFilter;

  ChatToSpeechConfiguration({
    required this.channels,
    required this.youtubeVideoId,
    required this.readUsername,
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
    required this.ignoreVtuberGroupName,
    required this.disableAKeongFilter,
  });

  ChatToSpeechConfiguration copyWith({
    Set<String>? channels,
    String? youtubeVideoId,
    bool? readUsername,
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
    bool? ignoreVtuberGroupName,
    bool? disableAKeongFilter,
  }) {
    return ChatToSpeechConfiguration(
      channels: channels ?? this.channels,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      readUsername: readUsername ?? this.readUsername,
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
      ignoreVtuberGroupName:
          ignoreVtuberGroupName ?? this.ignoreVtuberGroupName,
      disableAKeongFilter: disableAKeongFilter ?? this.disableAKeongFilter,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'channels': channels.toList()});
    result.addAll({'youtubeVideoId': youtubeVideoId});
    result.addAll({'readUsername': readUsername});
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
    result.addAll({'ignoreVtuberGroupName': ignoreVtuberGroupName});
    result.addAll({'disableAKeongFilter': disableAKeongFilter});

    return result;
  }

  factory ChatToSpeechConfiguration.fromMap(Map<String, dynamic> map) {
    return ChatToSpeechConfiguration(
      channels: Set<String>.from(map['channels']),
      youtubeVideoId: map["youtubeVideoId"] ?? "",
      readUsername: map['readUsername'] ?? true,
      ignoreExclamationMark: map['ignoreExclamationMark'] ?? true,
      ignoreEmotes: map['ignoreEmotes'] ?? true,
      languages: Set<Language>.from(
          map['languages']?.map((x) => LanguageParser.fromGoogle(x)) ??
              [Language.english, Language.indonesian, Language.japanese]),
      enabled:
          false, // For YouTube, always set to false as there's no guarantee that live video ID is still alive.
      volume: map['volume']?.toDouble() ?? 100.0,
      readBsr: map['readBsr'] ?? false,
      readBsrSafely: map['readBsrSafely'] ?? false,
      ttsSource: TtsSourceParser.fromString(map['ttsSource'] ?? '') ??
          TtsSource.google,
      filteredUsernames: Set<String>.from(map['filteredUsernames'] ?? []),
      isWhitelistingFilter: map['isWhitelistingFilter'] ?? false,
      ignoreEmptyMessage: map['ignoreEmptyMessage'] ?? true,
      ignoreUrls: map['ignoreUrls'] ?? true,
      ignoreVtuberGroupName: map['ignoreVtuberGroupName'] ?? true,
      disableAKeongFilter: map['disableAKeongFilter'] ?? false,
    );
  }

  String toJson() => _prettyJson(toMap());

  factory ChatToSpeechConfiguration.fromJson(String source) =>
      ChatToSpeechConfiguration.fromMap(json.decode(source));

  factory ChatToSpeechConfiguration.fromOldJson(String source) {
    final json = jsonDecode(source);
    final config = json["chatToSpeech"];
    final languages = Set<String>.from(
            config?["languages"] ?? ["indonesian", "english", "japanese"])
        .map((e) {
      switch (e) {
        case "indonesian":
          return Language.indonesian;
        case "japanese":
          return Language.japanese;
        case "english":
        default:
          return Language.english;
      }
    }).toSet();
    final volume = (config?["volume"]?.toDouble() ?? 0.0) * 100.0;

    return ChatToSpeechConfiguration(
      channels: Set<String>.from(config?["channels"] ?? []),
      youtubeVideoId: config?["youtubeVideoId"] ?? "",
      readUsername: config?["readUsername"] ?? true,
      ignoreExclamationMark: config?["ignoreExclamationMark"] ?? true,
      ignoreEmotes: true,
      languages: languages,
      enabled: config?["enabled"] ?? false,
      volume: volume,
      readBsr: config?["readBsr"] ?? false,
      readBsrSafely: false,
      ttsSource: TtsSource.google,
      filteredUsernames: Set<String>.from(config?["filteredUsernames"] ?? []),
      isWhitelistingFilter: config?["isWhitelistingFilter"] ?? false,
      ignoreEmptyMessage: true,
      ignoreUrls: true,
      ignoreVtuberGroupName: true,
      disableAKeongFilter: false,
    );
  }

  String _prettyJson(dynamic json) {
    var spaces = ' ' * 4;
    var encoder = JsonEncoder.withIndent(spaces);
    return encoder.convert(json);
  }
}
