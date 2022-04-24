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
    final config = context.watch<Config>();
    return ConfigGroup(
      title: "Beat Saber Specific",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Checkbox(
            checked: config.chatToSpeechConfiguration.readBsr,
            onChanged: (isChecked) {
              config.setBsrSpecificConfig(readBsr: isChecked ?? false);
            },
            content: const Text("Read !bsr song name"),
          ),
        ],
      ),
    );
  }
}
