import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';

class TtsConfigGroup extends StatelessWidget {
  const TtsConfigGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.watch<Config>();

    return ConfigGroup(
      title: "Text-to-speech",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Checkbox(
            checked: config.chatToSpeechConfiguration.readUsername,
            onChanged: (isChecked) {
              config.setTtsConfig(readUsername: isChecked);
            },
            content: const Text("Read username"),
          ),
          Checkbox(
            checked: config.chatToSpeechConfiguration.ignoreExclamationMark,
            onChanged: (isChecked) {
              config.setTtsConfig(ignoreExclamationMark: isChecked);
            },
            content: const Text("Skip messages starting with \"!\""),
          ),
          Checkbox(
            checked: config.chatToSpeechConfiguration.ignoreEmotes,
            onChanged: (isChecked) {
              config.setTtsConfig(ignoreEmotes: isChecked);
            },
            content: const Text("Ignore emotes"),
          ),
        ],
      ),
    );
  }
}
