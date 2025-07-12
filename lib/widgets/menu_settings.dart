import 'package:flutter/material.dart';

class MenuSettings extends StatelessWidget {
  final String title;
  final String? description;
  final String? subtitle;
  final Widget? left;
  final Widget? right;
  final Function() onPressed;

  const MenuSettings({
    super.key,
    required this.title,
    this.description,
    this.subtitle,
    required this.onPressed,
    this.left,
    this.right,
  });

  factory MenuSettings.submenu({
    key,
    required title,
    description,
    required onPressed,
    left,
  }) =>
      MenuSettings(
        key: key,
        onPressed: onPressed,
        title: title,
        description: description,
        left: left,
        right: const Icon(Icons.chevron_right),
      );

  @override
  Widget build(BuildContext context) {
    final left = this.left;
    final right = this.right;
    final description = this.description;
    final subtitle = this.subtitle;
    final theme = Theme.of(context);

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
        iconColor: theme.iconTheme.color,
        foregroundColor: theme.textTheme.bodyMedium?.color,
        textStyle: theme.textTheme.bodyMedium,
      ),
      onPressed: () {
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 40,
          ),
          child: Row(
            children: [
              if (left != null) left,
              const SizedBox(width: 12.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        children: [
                          Text(title),
                          if (description != null)
                            _DescriptionButton(description: description)
                        ],
                      ),
                      if (subtitle != null) const SizedBox(height: 2),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (right != null) right,
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionButton extends StatelessWidget {
  const _DescriptionButton({
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton.filledTonal(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(description),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        },
        icon: const Icon(
          Icons.question_mark,
          size: 12,
        ),
      ),
    );
  }
}
