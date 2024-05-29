import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';

class TtsConfigGroup extends StatelessWidget {
  const TtsConfigGroup({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ConfigGroup(
      title: "Text-to-speech",
      child: Wrap(
        direction: Axis.vertical,
        spacing: 8,
        children: [
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

class _AudioSourceDropDown extends StatelessWidget {
  const _AudioSourceDropDown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final selectedTtsSource = context
        .select((Config config) => config.chatToSpeechConfiguration.ttsSource);

    const ttsSources = TtsSource.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12.0),
        const Padding(
          padding: EdgeInsets.only(left: 2.0),
          child: Text("Speaker"),
        ),
        const SizedBox(height: 4.0),
        SizedBox(
          width: 200,
          child: DropDownButton(
            placement: FlyoutPlacementMode.left,
            title: Text(selectedTtsSource.displayName),
            items: ttsSources
                .map(
                  (e) => MenuFlyoutItem(
                    text: Text(e.displayName),
                    onPressed: () => config.setTtsSource(e),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
