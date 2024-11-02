import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class MessageCleanUpConfig extends StatelessWidget {
  const MessageCleanUpConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "Message Clean-up",
      children: [
        _RemoveEmotesConfig(),
        Divider(
          height: 1,
          indent: 28,
        ),
        _RemoveUrlsConfig(),
      ],
    );
  }
}

class _RemoveEmotesConfig extends StatelessWidget {
  const _RemoveEmotesConfig();

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreEmotes,
    );

    return SwitchSettings(
      isChecked: isChecked,
      title: "Remove emotes from message",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreEmotes: value);
      },
    );
  }
}

class _RemoveUrlsConfig extends StatelessWidget {
  const _RemoveUrlsConfig();

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreUrls,
    );

    return SwitchSettings(
      isChecked: isChecked,
      title: "Remove URLs from message",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreUrls: value);
      },
    );
  }
}
