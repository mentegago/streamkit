import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          indent: 50,
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
      title: "Remove emotes",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreEmotes: value);
      },
      left: const Icon(Icons.emoji_emotions),
    );
  }
}

class _RemoveBttvEmotesConfig extends StatelessWidget {
  const _RemoveBttvEmotesConfig();

  @override
  Widget build(BuildContext context) {
    final isIgnoringEmotes = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreEmotes,
    );

    final isIgnoringBttvEmotes = context.select(
      (Config config) => config.chatToSpeechConfiguration.ignoreBttvEmotes,
    );

    final iconThemeData = Theme.of(context).iconTheme;

    return AnimatedSize(
      duration: Durations.short4,
      child: isIgnoringEmotes
          ? Column(
              children: [
                SwitchSettings(
                  isChecked: isIgnoringBttvEmotes,
                  title: "Remove BetterTTV emotes",
                  onChanged: (value) {
                    context
                        .read<Config>()
                        .setTtsConfig(ignoreBttvEmotes: value);
                  },
                  left: Container(
                    width: iconThemeData.size,
                    height: iconThemeData.size,
                    padding: const EdgeInsets.all(2),
                    child: SvgPicture.asset(
                      "assets/images/betterttv_icon.svg",
                      colorFilter: ColorFilter.mode(
                        iconThemeData.color ?? Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  indent: 50,
                ),
              ],
            )
          : Container(),
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
      title: "Remove links / URLs",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreUrls: value);
      },
      left: const Icon(Icons.link_rounded),
    );
  }
}
