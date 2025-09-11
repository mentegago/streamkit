import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class LanguageDetectionConfigGroup extends HookWidget {
  const LanguageDetectionConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final showAllLanguages = useState<bool>(false);
        
    return ConfigContainer(
      title: "Auto Language Detection",
      children: [
        const _LanguageSwitch(
          language: Language.english,
        ),
        const Divider(
          height: 1,
          indent: 50,
        ),
        const _LanguageSwitch(
          language: Language.indonesian,
        ),
        const Divider(
          height: 1,
          indent: 50,
        ),
        const _LanguageSwitch(
          language: Language.japanese,
        ),
        AnimatedSize(
          duration: Durations.short4,
          child: showAllLanguages.value
              ? const Column(
                  children: [
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                    _LanguageSwitch(
                      language: Language.french,
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                    _LanguageSwitch(
                      language: Language.thai,
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                    _LanguageSwitch(
                      language: Language.arabic,
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                    _LanguageSwitch(
                      language: Language.hindi,
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                    ),
                    _LanguageSwitch(
                      language: Language.russian,
                    ),
                  ],
                )
              : Container(),
        ),
        const Divider(
          height: 1,
          indent: 50,
        ),
        MenuSettings.expandable(
          expanded: showAllLanguages.value,
          title: showAllLanguages.value ? "Show less languages" : "Show more languages",
          onPressed: () {
            showAllLanguages.value = !showAllLanguages.value;
          },
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
