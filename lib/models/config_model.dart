import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/enums/app_theme_mode.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';

class Config extends ChangeNotifier {
  ChatToSpeechConfiguration chatToSpeechConfiguration;

  Config({
    required this.chatToSpeechConfiguration,
  });

  void setEnabled(bool enabled) {
    chatToSpeechConfiguration =
        chatToSpeechConfiguration.copyWith(enabled: enabled);
    notifyListeners();
  }

  void setChatToSpeechConfiguration(ChatToSpeechConfiguration configuration) {
    chatToSpeechConfiguration = configuration;
    notifyListeners();
  }

  void setChannelUsernames(Set<String> username) {
    chatToSpeechConfiguration = chatToSpeechConfiguration.copyWith(
      channels: username,
    );
    notifyListeners();
  }

  void setYouTubeVideoId(String videoId) {
    chatToSpeechConfiguration = chatToSpeechConfiguration.copyWith(
      youtubeVideoId: videoId,
    );
    notifyListeners();
  }

  void setLanguage(Language language, {required bool enabled}) {
    if (enabled) {
      setChatToSpeechConfiguration(
        chatToSpeechConfiguration.copyWith(
          languages: {...chatToSpeechConfiguration.languages, language},
        ),
      );
    } else {
      setChatToSpeechConfiguration(
        chatToSpeechConfiguration.copyWith(
          languages: chatToSpeechConfiguration.languages
              .where((e) => e != language)
              .toSet(),
        ),
      );
    }
  }

  void setBsrSpecificConfig({
    bool? readBsr,
    bool? readBsrSafely,
  }) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        readBsr: readBsr ?? chatToSpeechConfiguration.readBsr,
        readBsrSafely: readBsrSafely ?? chatToSpeechConfiguration.readBsrSafely,
      ),
    );
  }

  void setTtsConfig({
    bool? readUsername,
    bool? ignoreEmptyMessage,
    bool? ignoreExclamationMark,
    bool? ignoreEmotes,
    bool? ignoreBttvEmotes,
    bool? ignoreFfzEmotes,
    bool? ignoreUrls,
    bool? ignoreVtuberGroupName,
  }) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        readUsername: readUsername ?? chatToSpeechConfiguration.readUsername,
        ignoreEmptyMessage:
            ignoreEmptyMessage ?? chatToSpeechConfiguration.ignoreEmptyMessage,
        ignoreExclamationMark: ignoreExclamationMark ??
            chatToSpeechConfiguration.ignoreExclamationMark,
        ignoreEmotes: ignoreEmotes ?? chatToSpeechConfiguration.ignoreEmotes,
        ignoreBttvEmotes:
            ignoreBttvEmotes ?? chatToSpeechConfiguration.ignoreBttvEmotes,
        ignoreUrls: ignoreUrls ?? chatToSpeechConfiguration.ignoreUrls,
        ignoreVtuberGroupName: ignoreVtuberGroupName ??
            chatToSpeechConfiguration.ignoreVtuberGroupName,
      ),
    );
  }

  void setVolume(double volume) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        volume: volume,
      ),
    );
  }

  void setTtsSource(TtsSource source) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        ttsSource: source,
      ),
    );
  }

  void setUserFilter(
      {required Set<String> usernames, required bool isWhitelistingFilter}) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        isWhitelistingFilter: isWhitelistingFilter,
        filteredUserIds: usernames,
      ),
    );
  }

  void setThemeMode(AppThemeMode themeMode) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        themeMode: themeMode,
      ),
    );
  }
}
