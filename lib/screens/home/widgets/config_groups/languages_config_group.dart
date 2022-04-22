import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/screens/home/config_group.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/text_with_flag.dart';

class LanguagesConfigGroup extends StatelessWidget {
  const LanguagesConfigGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languages = [
      Language.indonesian,
      Language.english,
      Language.japanese,
    ];

    final config = context.watch<Config>();
    final activeLanguages = config.chatToSpeechConfiguration.languages;

    final languageWidgets = languages.map(
      (e) => Checkbox(
        checked: activeLanguages.contains(e),
        onChanged: (isChecked) =>
            config.setLanguage(e, enabled: isChecked ?? false),
        content: TextWithFlag(
          flagCode: e.flagCode,
          text: e.displayName,
        ),
      ),
    );

    return ConfigGroup(
      title: "Languages",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          ...languageWidgets,
        ],
      ),
    );
  }
}
