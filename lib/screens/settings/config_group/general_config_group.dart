import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class GeneralConfig extends StatelessWidget {
  const GeneralConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "General",
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
      title: "Read username",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(readUsername: value);
      },
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
      (Config config) =>
          config.chatToSpeechConfiguration.readUsernameOnEmptyMessage,
    );

    return isReadUsernameChecked
        ? Column(
            children: [
              const Divider(
                height: 1,
                indent: 28,
              ),
              SwitchSettings(
                isChecked: isChecked,
                title:
                    "Read username even if there is no readable message content",
                description:
                    "If the option to remove emotes or URLs is on, StreamKit will read the sender's username when a chat message has no readable content (only emotes or URLs).\n\nIf the option is off, StreamKit will skip the message.",
                onChanged: (value) {
                  context
                      .read<Config>()
                      .setTtsConfig(readUsernameOnEmptyMessage: value);
                },
              ),
            ],
          )
        : const SizedBox();
  }
}
