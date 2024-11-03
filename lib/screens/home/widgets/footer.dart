import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

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
