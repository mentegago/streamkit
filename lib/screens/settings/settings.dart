import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrollController = useScrollController();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Wrap(
                  runSpacing: 24.0,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 28.0, left: 8.0),
                      child: Text(
                        "Settings",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const LanguageDetectionConfig(),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              padding: const EdgeInsets.only(top: 32.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageDetectionConfig extends StatelessWidget {
  const LanguageDetectionConfig({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            bottom: 8.0,
          ),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "Auto Language Detection",
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LanguageSwitch(
                  language: Language.english,
                ),
                Divider(
                  height: 1,
                  indent: 32,
                ),
                LanguageSwitch(
                  language: Language.indonesian,
                ),
                Divider(
                  height: 1,
                  indent: 32,
                ),
                LanguageSwitch(
                  language: Language.japanese,
                ),
                Divider(
                  height: 1,
                  indent: 32,
                ),
                LanguageSwitch(
                  language: Language.french,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageSwitch extends StatelessWidget {
  final Language language;

  const LanguageSwitch({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) =>
          config.chatToSpeechConfiguration.languages.contains(language),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Flag.fromCode(
            language.flagCode,
            height: 21,
            width: 21,
          ),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(language.displayName),
          ),
          Switch(
            value: isChecked,
            onChanged: (value) {
              context.read<Config>().setLanguage(language, enabled: value);
            },
          )
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Settings",
              style: theme.textTheme.titleLarge,
            ),
          ),
          IconButton.outlined(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
