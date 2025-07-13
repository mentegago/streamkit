import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/app_theme_mode.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/radio_settings.dart';

class ThemeConfigGroup extends StatelessWidget {
  const ThemeConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select(
      (Config config) => config.chatToSpeechConfiguration.themeMode,
    );

    return ConfigContainer(
      title: "Theme",
      children: [
        RadioSettings<AppThemeMode>(
          options: const [
            RadioOption(
              value: AppThemeMode.dark,
              title: "Dark Mode",
              icon: Icons.dark_mode,
            ),
            RadioOption(
              value: AppThemeMode.light,
              title: "Light Mode (Experimental)",
              icon: Icons.light_mode,
            ),
          ],
          selectedValue: themeMode,
          onChanged: (value) {
            context.read<Config>().setThemeMode(value);

            if (value == AppThemeMode.light) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text('Throwing Flashbang!'),
                    ],
                  ),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
