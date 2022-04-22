import 'package:fluent_ui/fluent_ui.dart';

class ConfigGroup extends StatelessWidget {
  const ConfigGroup({
    Key? key,
    required this.child,
    required this.title,
  }) : super(key: key);

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FluentTheme.of(context).typography.bodyLarge,
        ),
        child,
      ],
    );
  }
}
