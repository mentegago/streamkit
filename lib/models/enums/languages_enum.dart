import 'package:flag/flag_enum.dart';

enum Language { 
  english, 
  indonesian, 
  japanese, 
  french, 
  thai, 
  arabic,
  hindi,
  russian,
}

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
      case Language.thai:
        return 'th';
      case Language.arabic:
        return 'ar';
      case Language.hindi:
        return 'hi';
      case Language.russian:
        return 'ru';
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
      case Language.thai:
        return 'Thai';
      case Language.arabic:
        return 'Arabic';
      case Language.hindi:
        return 'Hindi';
      case Language.russian:
        return 'Russian';
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
      case Language.thai:
        return 'TH';
      case Language.arabic:
        return 'AR';
      case Language.hindi:
        return 'HI';
      case Language.russian:
        return 'RU';
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
      case Language.thai:
        return FlagsCode.TH;
      case Language.arabic:
        return FlagsCode.SA;
      case Language.hindi:
        return FlagsCode.IN;
      case Language.russian:
        return FlagsCode.RU;
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
      case "th":
        return Language.thai;
      case "ar":
        return Language.arabic;
      case "hi":
        return Language.hindi;
      case "ru":
        return Language.russian;
      default:
        return null;
    }
  }

  static Language? fromForceCode(String lang) {
    switch (lang) {
      case "EN" || "?EN":
        return Language.english;
      case "ID" || "?ID":
        return Language.indonesian;
      case "JP" || "?JP":
        return Language.japanese;
      case "FR" || "?FR":
        return Language.french;
      case "?TH":
        return Language.thai;
      case "?AR":
        return Language.arabic;
      case "?HI":
        return Language.hindi;
      case "?RU":
        return Language.russian;
      default:
        return null;
    }
  }
}
