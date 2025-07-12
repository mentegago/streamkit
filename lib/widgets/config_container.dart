import 'package:flutter/material.dart';

class ConfigContainer extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final Widget? right;
  final List<Widget> children;

  const ConfigContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.right,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    final right = this.right;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            bottom: 8.0,
            right: 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (subtitle != null) subtitle,
                  ],
                ),
              ),
              if (right != null) right,
            ],
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
