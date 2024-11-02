import 'package:flutter/material.dart';

class ConfigContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ConfigContainer({
    super.key,
    required this.title,
    required this.children,
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
              title,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
