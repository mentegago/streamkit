enum TtsSource { google, tiktok }

extension TtsSourceExtension on TtsSource {
  String get string {
    switch (this) {
      case TtsSource.google:
        return 'google';
      case TtsSource.tiktok:
        return 'tiktok';
    }
  }

  String get displayName {
    switch (this) {
      case TtsSource.google:
        return 'Google Translate';
      case TtsSource.tiktok:
        return 'TikTok';
    }
  }
}

class TtsSourceParser {
  static TtsSource? fromString(String string) {
    switch (string) {
      case 'google':
        return TtsSource.google;
      case 'tiktok':
        return TtsSource.tiktok;
    }
    return null;
  }
}
