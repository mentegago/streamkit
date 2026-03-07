import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/flavor_config.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/menu_settings.dart';
import 'package:streamkit_tts/widgets/switch_settings.dart';

class MessageCleanUpConfig extends StatelessWidget {
  const MessageCleanUpConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfigContainer(
      title: "Message Clean-up",
      children: [
        _RemoveEmotesConfig(),
        Divider(height: 1, indent: 50),
        if (FlavorConfig.isTwitch) _RemoveBttvEmotesConfig(),
        _RemoveUrlsConfig(),
        Divider(height: 1, indent: 50),
        _FindAndReplaceConfig(),
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
      title: "Don't read emotes",
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
                  title: "Don't read BetterTTV emotes",
                  onChanged: (value) {
                    context
                        .read<Config>()
                        .setTtsConfig(ignoreBttvEmotes: value);
                  },
                  left: SizedBox(
                    width: (iconThemeData.size ?? 1) - 6,
                    height: (iconThemeData.size ?? 1) - 6,
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
      title: "Don't read links / URLs",
      onChanged: (value) {
        context.read<Config>().setTtsConfig(ignoreUrls: value);
      },
      left: const Icon(Icons.link_rounded),
    );
  }
}

class _FindAndReplaceConfig extends StatelessWidget {
  const _FindAndReplaceConfig();

  @override
  Widget build(BuildContext context) {
    return MenuSettings.submenu(
      title: "Find & Replace",
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/settings/replace_strings',
        );
      },
      left: const Icon(Icons.find_replace),
    );
  }
}
