import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class FilterConfig extends StatelessWidget {
  const FilterConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigContainer(
      title: "Filters",
      children: [
        const _SkipExclamationConfig(),
        const Divider(
          height: 1,
          indent: 28,
        ),
        MenuSettings.submenu(title: "User Filter", onPressed: () {}),
      ],
    );
  }
}

class _SkipExclamationConfig extends StatelessWidget {
  const _SkipExclamationConfig();

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreExclamationMark,
    );

    return SwitchSettings(
      isChecked: isChecked,
      title: "Skip messages starting with \"!\"",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreExclamationMark: value);
      },
    );
  }
}
