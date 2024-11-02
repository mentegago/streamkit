import 'package:flutter/material.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';

class SwitchSettings extends StatelessWidget {
  final bool isChecked;
  final String title;
  final String? description;
  final Widget? left;
  final Function(bool value) onChanged;

  const SwitchSettings({
    super.key,
    required this.isChecked,
    required this.title,
    this.description,
    required this.onChanged,
    this.left,
  });

  @override
  Widget build(BuildContext context) => MenuSettings(
        title: title,
        onPressed: () {
          onChanged(!isChecked);
        },
        description: description,
        left: left,
        right: Switch(
          value: isChecked,
          onChanged: onChanged,
        ),
      );
}
