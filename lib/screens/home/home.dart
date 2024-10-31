import 'package:flutter/material.dart';
import 'package:streamkit_tts/screens/home/widgets/main_control.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: MainControl(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SettingsButton(),
            )
          ],
        ),
      ),
      // backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/settings',
        );
      },
      style: TextButton.styleFrom(padding: const EdgeInsets.all(18)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings),
          SizedBox(
            width: 8,
          ),
          Text("Settings"),
        ],
      ),
    );
  }
}
