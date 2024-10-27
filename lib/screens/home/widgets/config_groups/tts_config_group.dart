import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';

class TtsConfigGroup extends StatelessWidget {
  const TtsConfigGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConfigGroup(
      title: "Text-to-speech",
      child: Wrap(
        direction: Axis.vertical,
        spacing: 8,
        children: [
          const SizedBox(height: 8.0),
          _ReadUsernameCheckbox(),
          _IgnoreExclamationCheckbox(),
          _IgnoreEmotesCheckbox(),
          _RemoveUrls(),
        ],
      ),
    );
  }
}

class _IgnoreEmotesCheckbox extends StatelessWidget {
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
      content: const Text("Remove emotes"),
    );
  }
}

class _IgnoreExclamationCheckbox extends StatelessWidget {
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

class _RemoveUrls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final ignoreUrls = context
        .select((Config config) => config.chatToSpeechConfiguration.ignoreUrls);

    return Checkbox(
      checked: ignoreUrls,
      onChanged: (isChecked) {
        config.setTtsConfig(ignoreUrls: isChecked);
      },
      content: const Text("Remove URLs"),
    );
  }
}

class _AudioSourceDropDown extends StatelessWidget {
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
