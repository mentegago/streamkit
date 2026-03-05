import 'package:collection/collection.dart';
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

  final priorityLanguages = const {
    Language.english,
    Language.indonesian,
    Language.japanese,
  };

  final languages = const [
    Language.english,
    Language.indonesian,
    Language.japanese,
    Language.french,
    Language.thai,
    Language.arabic,
    Language.hindi,
    Language.russian,
  ];

  @override
  Widget build(BuildContext context) {
    final showAllLanguages = useState<bool>(false);

    final selectedLanguages = useMemoized(
        () => context.read<Config>().chatToSpeechConfiguration.languages);
    final sortedLanguages = useMemoized(() {
      // Priority languages are at the top, followed by selected languages, followed by the rest of the languages.
      return languages.toList()
        ..sort((a, b) {
          final aIndex = languages.indexOf(a) +
              (priorityLanguages.contains(a)
                  ? 0
                  : selectedLanguages.contains(a)
                      ? 1000
                      : 10000);
          final bIndex = languages.indexOf(b) +
              (priorityLanguages.contains(b)
                  ? 0
                  : selectedLanguages.contains(b)
                      ? 1000
                      : 10000);

          return aIndex.compareTo(bIndex);
        });
    }, [selectedLanguages]);

    final initialDisplayedLanguages = useMemoized(() {
      // Only display priority languages and selected languages.
      return sortedLanguages
          .asMap()
          .entries
          .where(
            (e) =>
                priorityLanguages.contains(e.value) ||
                selectedLanguages.contains(e.value),
          )
          .map((e) => e.value)
          .toList();
    }, [sortedLanguages]);

    final languageWidgets = useMemoized(() {
      return (showAllLanguages.value
              ? sortedLanguages
              : initialDisplayedLanguages)
          .mapIndexed((index, language) => [
                if (index != 0) const Divider(height: 1, indent: 50),
                _LanguageSwitch(language: language)
              ])
          .expand((e) => e)
          .toList();
    }, [showAllLanguages.value, sortedLanguages, initialDisplayedLanguages]);

    return ConfigContainer(
      title: "Auto Language Detection",
      children: [
        AnimatedSize(
          curve: Curves.easeInOut,
          duration: Durations.short4,
          alignment: Alignment.topLeft,
          child: Column(
            children: languageWidgets,
          ),
        ),
        if (sortedLanguages.length > initialDisplayedLanguages.length) ...[
          const Divider(height: 1, indent: 50),
          MenuSettings.expandable(
            expanded: showAllLanguages.value,
            title: showAllLanguages.value
                ? "Show less languages"
                : "Show more languages",
            onPressed: () {
              showAllLanguages.value = !showAllLanguages.value;
            },
          ),
        ],
      ],
    );
  }
}

class _LanguageSwitch extends StatelessWidget {
  final Language language;
  final String? description;

  const _LanguageSwitch({
    required this.language,
    // ignore: unused_element_parameter
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) =>
          config.chatToSpeechConfiguration.languages.contains(language),
    );

    return SwitchSettings(
      key: Key(language.name),
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
