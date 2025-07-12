import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';

class IntegrationsConfigGroup extends StatelessWidget {
  const IntegrationsConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final iconThemeData = Theme.of(context).iconTheme;

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
          left: SvgPicture.asset(
            "assets/images/beatsaber_icon.svg",
            colorFilter: ColorFilter.mode(
              iconThemeData.color ?? Colors.white,
              BlendMode.srcIn,
            ),
            width: iconThemeData.size,
            height: iconThemeData.size,
          ),
        ),
      ],
    );
  }
}
