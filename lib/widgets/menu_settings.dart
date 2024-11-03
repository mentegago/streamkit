import 'package:flutter/material.dart';

class MenuSettings extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? left;
  final Widget? right;
  final Function() onPressed;

  const MenuSettings({
    super.key,
    required this.title,
    this.description,
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
        child: SizedBox(
          height: 40.0,
          child: Row(
            children: [
              if (left != null) left,
              const SizedBox(width: 12.0),
              Expanded(
                child: Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6.0,
                  children: [
                    Text(title),
                    if (description != null)
                      _DescriptionButton(description: description)
                  ],
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
