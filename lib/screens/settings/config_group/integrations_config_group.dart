import 'package:flutter/material.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';

class IntegrationsConfigGroup extends StatelessWidget {
  const IntegrationsConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigContainer(
      title: "Game Integrations",
      children: [
        MenuSettings.submenu(
          title: "Beat Saber",
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/settings/beat_saber',
            );
          },
        ),
      ],
    );
  }
}
