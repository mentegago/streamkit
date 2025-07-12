import 'package:flutter/material.dart';

class ActionButton {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const ActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });
}

class ActionListItem extends StatelessWidget {
  final String title;
  final Widget? left;
  final List<ActionButton> actions;

  const ActionListItem({
    super.key,
    required this.title,
    this.left,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = this.left;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: SizedBox(
        height: 40.0,
        child: Row(
          children: [
            if (left != null) left,
            if (left != null) const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            ...actions.map((action) => _ActionButton(action: action)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ActionButton action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: IconButton(
        onPressed: action.onPressed,
        icon: Icon(action.icon),
        tooltip: action.tooltip,
        style: IconButton.styleFrom(
          foregroundColor: action.color,
          minimumSize: const Size(32, 32),
          iconSize: 18,
        ),
      ),
    );
  }
}
