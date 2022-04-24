import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';

class BeatSaberConfigGroup extends StatelessWidget {
  const BeatSaberConfigGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigGroup(
      title: "Beat Saber Specific",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 8.0),
          _ReadBsrCheckbox(),
        ],
      ),
    );
  }
}

class _ReadBsrCheckbox extends StatelessWidget {
  const _ReadBsrCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final readBsr = context
        .select((Config config) => config.chatToSpeechConfiguration.readBsr);

    return Checkbox(
      checked: readBsr,
      onChanged: (isChecked) {
        config.setBsrSpecificConfig(readBsr: isChecked ?? false);
      },
      content: const Text("Read !bsr song name"),
    );
  }
}
