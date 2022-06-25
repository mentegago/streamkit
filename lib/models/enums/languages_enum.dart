import 'package:flag/flag_enum.dart';

enum Language { english, indonesian, japanese, french }

extension LanguageExtension on Language {
  String get google {
    switch (this) {
      case Language.english:
        return 'en-US';
      case Language.indonesian:
        return 'id-ID';
      case Language.japanese:
        return 'ja';
      case Language.french:
        return 'fr';
    }
  }

  String get tikTokSpeaker {
    switch (this) {
      case Language.english:
        return 'en_us_001';
      case Language.indonesian:
        return 'id_001';
      case Language.japanese:
        return 'jp_001';
      case Language.french:
        return 'fr_001';
    }
  }

  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.indonesian:
        return 'Indonesian';
      case Language.japanese:
        return 'Japanese';
      case Language.french:
        return 'French';
    }
  }

  // Messages that starts with this code (case sensitive), followed by space, will be recognized as its language.
  // Example: "ID hello world" will be recognized as Indonesian despite "hello world" being an English sentence.
  String get forceCode {
    switch (this) {
      case Language.english:
        return 'EN';
      case Language.indonesian:
        return 'ID';
      case Language.japanese:
        return 'JP';
      case Language.french:
        return 'FR';
    }
  }

  FlagsCode get flagCode {
    switch (this) {
      case Language.english:
        return FlagsCode.US;
      case Language.indonesian:
        return FlagsCode.ID;
      case Language.japanese:
        return FlagsCode.JP;
      case Language.french:
        return FlagsCode.FR;
    }
  }
}

class LanguageParser {
  static Language? fromGoogle(String lang) {
    switch (lang) {
      case "en-US":
        return Language.english;
      case "id-ID":
        return Language.indonesian;
      case "ja":
        return Language.japanese;
      case "fr":
        return Language.french;
      default:
        return null;
    }
  }

  static Language? fromForceCode(String lang) {
    switch (lang) {
      case "EN":
        return Language.english;
      case "ID":
        return Language.indonesian;
      case "JP":
        return Language.japanese;
      case "FR":
        return Language.french;
      default:
        return null;
    }
  }
}
