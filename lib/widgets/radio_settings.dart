import 'package:flutter/material.dart';

class RadioOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? selectedColor;

  const RadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    required this.icon,
    this.selectedColor,
  });
}

class RadioSettings<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  const RadioSettings({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          _RadioOptionWidget<T>(
            option: options[i],
            isSelected: options[i].value == selectedValue,
            onTap: () => onChanged(options[i].value),
          ),
          if (i < options.length - 1) const Divider(height: 1, indent: 16),
        ],
      ],
    );
  }
}

class _RadioOptionWidget<T> extends StatelessWidget {
  final RadioOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOptionWidget({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = option.selectedColor ?? theme.colorScheme.primary;
    final subtitle = option.subtitle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 24,
                color: isSelected
                    ? selectedColor
                    : theme.iconTheme.color?.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? selectedColor
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    subtitle != null
                        ? Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? selectedColor
                    : theme.iconTheme.color?.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
