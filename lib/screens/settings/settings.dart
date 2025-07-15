import 'package:flutter/material.dart';
import 'package:streamkit_tts/screens/settings/config_group/theme_config_group.dart';
import 'package:streamkit_tts/screens/settings/config_group/filter_config_group.dart';
import 'package:streamkit_tts/screens/settings/config_group/username_config_group.dart';
import 'package:streamkit_tts/screens/settings/config_group/integrations_config_group.dart';
import 'package:streamkit_tts/screens/settings/config_group/language_detection_config_group.dart';
import 'package:streamkit_tts/screens/settings/config_group/message_cleanup_config_group.dart';
import 'package:streamkit_tts/widgets/inner_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const InnerScreen(
        title: "Settings",
        children: [
          LanguageDetectionConfigGroup(),
          MessageCleanUpConfig(),
          UsernameConfig(),
          FilterConfig(),
          IntegrationsConfigGroup(),
          ThemeConfigGroup(),
        ],
      );
}
