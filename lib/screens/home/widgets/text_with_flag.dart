import 'package:flag/flag.dart';
import 'package:fluent_ui/fluent_ui.dart';

class TextWithFlag extends StatelessWidget {
  const TextWithFlag({
    Key? key,
    required this.flagCode,
    required this.text,
  }) : super(key: key);

  final FlagsCode flagCode;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        Flag.fromCode(
          flagCode,
          height: 21,
          width: 21,
        ),
        Text(text)
      ],
    );
  }
}
