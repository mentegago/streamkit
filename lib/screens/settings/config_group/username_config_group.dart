import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class UsernameConfig extends StatelessWidget {
  const UsernameConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "Name handling",
      children: [
        _ReadUsernameConfig(),
        _ReadUsernameEmptyMessageConfig(),
      ],
    );
  }
}

class _ReadUsernameConfig extends StatelessWidget {
  const _ReadUsernameConfig();

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.readUsername,
    );

    return SwitchSettings(
      isChecked: isChecked,
      title: "Read chat sender's name",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(readUsername: value);
      },
      left: const Icon(Icons.speaker_notes_rounded),
    );
  }
}

class _ReadUsernameEmptyMessageConfig extends StatelessWidget {
  const _ReadUsernameEmptyMessageConfig();

  @override
  Widget build(BuildContext context) {
    final isReadUsernameChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.readUsername,
    );

    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreEmptyMessage,
    );

    return AnimatedSize(
      duration: Durations.short4,
      child: isReadUsernameChecked
          ? Column(
              children: [
                const Divider(
                  height: 1,
                  indent: 50,
                ),
                SwitchSettings(
                  isChecked: !isChecked,
                  title: "Read name even when there is no readable message",
                  subtitle: isChecked
                      ? "StreamKit will not read the sender's name if it has no readable content"
                      : "StreamKit will always read the sender's name",
                  onChanged: (value) {
                    context
                        .read<Config>()
                        .setTtsConfig(ignoreEmptyMessage: !value);
                  },
                  left: const Icon(Icons.chat_bubble),
                ),
              ],
            )
          : Container(),
    );
  }
}
