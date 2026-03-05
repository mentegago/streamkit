// Build with --dart-define=FLAVOR=youtube for the YouTube flavor.
// Default (no dart-define) is the Twitch flavor.
//
// All values are compile-time constants — the Dart AOT compiler tree-shakes
// dead branches in release builds, so the unused flavor's code is absent
// from the final binary.
//
// Usage:
//   flutter build windows --release                          → Twitch
//   flutter build windows --release --dart-define=FLAVOR=youtube → YouTube

const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'twitch');

class FlavorConfig {
  static const bool isYouTube = _flavor == 'youtube';
  static const bool isTwitch = !isYouTube;
  static const String configFileName =
      isYouTube ? 'config_youtube.json' : 'config.json';
}
