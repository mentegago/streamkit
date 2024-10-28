import 'package:fluent_ui/fluent_ui.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/tts_source.dart';
import 'package:streamkit_tts/screens/home/widgets/config_group.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/dialogs/blacklist_dialog.dart';

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
          _RemoveVtuberGroupName(),
          _IgnoreExclamationCheckbox(),
          _IgnoreEmotesCheckbox(),
          _RemoveUrls(),
          const SizedBox(height: 1.0),
          Button(
            child: const Text("Change Filtered Users"),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BlacklistDialog(),
              );
            },
          ),
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
      content: const Text("Read name"),
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

class _RemoveVtuberGroupName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final ignoreVtuberGroupName = context.select((Config config) =>
        config.chatToSpeechConfiguration.ignoreVtuberGroupName);

    return Checkbox(
      checked: ignoreVtuberGroupName,
      onChanged: (isChecked) {
        config.setTtsConfig(ignoreVtuberGroupName: isChecked);
      },
      content: const Text("Remove Vtuber Group Name"),
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
