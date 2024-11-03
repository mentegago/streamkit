import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class LanguageDetectionConfigGroup extends StatelessWidget {
  const LanguageDetectionConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "Auto Language Detection",
      children: [
        _LanguageSwitch(
          language: Language.english,
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        _LanguageSwitch(
          language: Language.indonesian,
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        _LanguageSwitch(
          language: Language.japanese,
        ),
        Divider(
          height: 1,
          indent: 50,
        ),
        _LanguageSwitch(
          language: Language.french,
        ),
      ],
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  final Language language;
  final String? description;

  const _LanguageSwitch({
    required this.language,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) =>
          config.chatToSpeechConfiguration.languages.contains(language),
    );

    return SwitchSettings(
      isChecked: isChecked,
      title: language.displayName,
      description: description,
      onChanged: (value) {
        context.read<Config>().setLanguage(language, enabled: value);
      },
      left: Flag.fromCode(
        language.flagCode,
        height: 21,
        width: 21,
      ),
    );
  }
}
