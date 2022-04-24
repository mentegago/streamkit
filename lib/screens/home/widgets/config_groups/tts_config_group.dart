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
    return ConfigGroup(
      title: "Text-to-speech",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 8.0),
          _ReadUsernameCheckbox(),
          _IgnoreExclamationCheckbox(),
          _IgnoreEmotesCheckbox(),
        ],
      ),
    );
  }
}

class _IgnoreEmotesCheckbox extends StatelessWidget {
  const _IgnoreEmotesCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final ignoreEmotes = context.select(
        (Config config) => config.chatToSpeechConfiguration.ignoreEmotes);

    return Checkbox(
      checked: ignoreEmotes,
      onChanged: (isChecked) {
        config.setTtsConfig(ignoreEmotes: isChecked);
      },
      content: const Text("Ignore emotes"),
    );
  }
}

class _IgnoreExclamationCheckbox extends StatelessWidget {
  const _IgnoreExclamationCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final ignoreExclamationMark = context.select((Config config) =>
        config.chatToSpeechConfiguration.ignoreExclamationMark);

    return Checkbox(
      checked: ignoreExclamationMark,
      onChanged: (isChecked) {
        config.setTtsConfig(ignoreExclamationMark: isChecked);
      },
      content: const Text("Skip messages starting with \"!\""),
    );
  }
}

class _ReadUsernameCheckbox extends StatelessWidget {
  const _ReadUsernameCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final readUsername = context.select(
        (Config config) => config.chatToSpeechConfiguration.readUsername);

    return Checkbox(
      checked: readUsername,
      onChanged: (isChecked) {
        config.setTtsConfig(readUsername: isChecked);
      },
      content: const Text("Read username"),
    );
  }
}
