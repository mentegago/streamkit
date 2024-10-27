import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/chat_to_speech_config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
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
    bool? ignoreExclamationMark,
    bool? ignoreEmotes,
    bool? ignoreUrls,
  }) {
    setChatToSpeechConfiguration(
      chatToSpeechConfiguration.copyWith(
        readUsername: readUsername ?? chatToSpeechConfiguration.readUsername,
        ignoreExclamationMark: ignoreExclamationMark ??
            chatToSpeechConfiguration.ignoreExclamationMark,
        ignoreEmotes: ignoreEmotes ?? chatToSpeechConfiguration.ignoreEmotes,
        ignoreUrls: ignoreUrls ?? chatToSpeechConfiguration.ignoreUrls,
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
}
