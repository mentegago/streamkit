import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/text_with_flag.dart';

class LanguagesConfigGroup extends StatelessWidget {
  const LanguagesConfigGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      Language.indonesian,
      Language.english,
      Language.japanese,
      Language.french,
    ];

    final languageWidgets = languages.map(
      (e) => _LanguageCheckbox(language: e),
    );

    return ConfigGroup(
      title: "Languages",
      tooltip:
          "StreamKit will detect the language pattern of each chat message and choose one of the selected language that matches the most.",
      child: Wrap(
        direction: Axis.vertical,
        spacing: 8,
        children: [
          const SizedBox(height: 8.0),
          ...languageWidgets,
        ],
      ),
    );
  }
}

class _LanguageCheckbox extends StatelessWidget {
  const _LanguageCheckbox({
    super.key,
    required this.language,
  });

  final Language language;

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final isChecked = context.select((Config config) =>
        config.chatToSpeechConfiguration.languages.contains(language));

    return Checkbox(
      checked: isChecked,
      onChanged: (isChecked) =>
          config.setLanguage(language, enabled: isChecked ?? false),
      content: TextWithFlag(
        flagCode: language.flagCode,
        text: language.displayName,
      ),
    );
  }
}
