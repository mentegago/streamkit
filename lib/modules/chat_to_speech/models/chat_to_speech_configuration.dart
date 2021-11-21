import 'package:streamkit/modules/enums/language.dart';

class ChatToSpeechConfiguration {
  final List<String> channels;
  final bool readUsername;
  final bool ignoreExclamationMark;
  final Set<Language> languages;
  final bool enabled;

  ChatToSpeechConfiguration({
    required this.channels,
    required this.readUsername,
    required this.ignoreExclamationMark,
    required this.languages,
    required this.enabled,
  });
}
