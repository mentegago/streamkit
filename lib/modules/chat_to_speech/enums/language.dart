import 'package:flag/flag_enum.dart';

enum Language { english, indonesian, japanese }

extension LanguageExtension on Language {
  String get google {
    switch (this) {
      case Language.english:
        return 'en-US';
      case Language.indonesian:
        return 'id-ID';
      case Language.japanese:
        return 'ja';
    }
  }

  String get franc {
    switch (this) {
      case Language.english:
        return 'eng';
      case Language.indonesian:
        return 'ind';
      case Language.japanese:
        return 'jpn';
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
    }
  }
}

class LanguageParser {
  static Language? fromFranc(String lang) {
    switch (lang) {
      case "eng":
        return Language.english;
      case "ind":
        return Language.indonesian;
      case "jpn":
        return Language.japanese;
      default:
        return null;
    }
  }

  static Language? fromGoogle(String lang) {
    switch (lang) {
      case "en-US":
        return Language.english;
      case "id-ID":
        return Language.indonesian;
      case "ja":
        return Language.japanese;
      default:
        return null;
    }
  }
}
