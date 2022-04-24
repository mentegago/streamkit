import 'package:fluent_ui/fluent_ui.dart';

class ConfigGroup extends StatelessWidget {
  const ConfigGroup({
    Key? key,
    required this.child,
    required this.title,
    this.tooltip = "",
  }) : super(key: key);

  final Widget child;
  final String title;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: FluentTheme.of(context).typography.bodyLarge,
            ),
            if (tooltip.isNotEmpty)
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Tooltip(
                  style: const TooltipThemeData(waitDuration: Duration.zero),
                  message: tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.help,
                    child: IconButton(
                      iconButtonMode: IconButtonMode.small,
                      icon: const Icon(FluentIcons.status_circle_question_mark),
                      onPressed: () {},
                    ),
                  ),
                ),
              )
          ],
        ),
        child,
      ],
    );
  }
}
