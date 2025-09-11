import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/inner_screen.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class BeatSaberSettingsScreen extends StatelessWidget {
  const BeatSaberSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const InnerScreen(
        title: "Beat Saber Integration",
        children: [
          _BeatSaberConfigGroup(),
        ],
      );
}

class _BeatSaberConfigGroup extends StatelessWidget {
  const _BeatSaberConfigGroup();

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "Song request",
      children: [
        _ReadBsrRequests(),
        _ReadBsrRequestsSafely(),
      ],
    );
  }
}

class _ReadBsrRequests extends StatelessWidget {
  const _ReadBsrRequests();

  @override
  Widget build(BuildContext context) {
    final isChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.readBsr,
    );

    return SwitchSettings(
      isChecked: isChecked,
      left: const Icon(Icons.notification_important),
      title: "Announce !bsr song request",
      onChanged: (value) {
        context.read<Config>().setBsrSpecificConfig(readBsr: value);
      },
    );
  }
}

class _ReadBsrRequestsSafely extends StatelessWidget {
  const _ReadBsrRequestsSafely();

  @override
  Widget build(BuildContext context) {
    final isBsrChecked = context.select(
      (Config config) => config.chatToSpeechConfiguration.readBsr,
    );

    final isChecked = context.select(
      (Config config) => !config.chatToSpeechConfiguration.readBsrSafely,
    );

    return AnimatedSize(
      duration: Durations.short4,
      child: isBsrChecked
          ? Column(
              children: [
                const Divider(
                  height: 1,
                  indent: 28,
                ),
                SwitchSettings(
                  isChecked: isChecked,
                  left: const Icon(Icons.music_note),
                  title: "Read the requested song name",
                  subtitle: "Enable to include the song name in the announcement",
                  onChanged: (value) {
                    context
                        .read<Config>()
                        .setBsrSpecificConfig(readBsrSafely: !value);
                  },
                ),
              ],
            )
          : Container(),
    );
  }
}
