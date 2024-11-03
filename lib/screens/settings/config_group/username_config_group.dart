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
                  title: "Read even when there is no readable message",
                  description:
                      "If this option is turned on, StreamKit will read the chat sender's name even when the chat has no readable content (such as when it only contain emotes, and \"Remove emotes from message\" option is turned on).\n\nIf this option is off, StreamKit will skip the chat.",
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
