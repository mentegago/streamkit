import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/twitch_channel_selection_dialog.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';

class TwitchChannelBox extends StatelessWidget {
  const TwitchChannelBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = FluentTheme.of(context);
    final channels = context
        .select((Config config) => config.chatToSpeechConfiguration.channels);

    final List<Widget> channelInfoWidgets = (() {
      if (channels.isEmpty) {
        return [
          const Expanded(
            child: Text("No channel selected."),
          ),
        ];
      } else {
        return [
          Text("Channel:", style: themeData.typography.bodyStrong),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              channels.join(", "),
            ),
          ),
        ];
      }
    })();

    return FluentTheme(
      data: ThemeData(brightness: Brightness.dark),
      child: Card(
        backgroundColor:
            const Color.fromARGB(255, 100, 65, 165).toAccentColor(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              SvgPicture.asset("assets/images/twitch_icon.svg", height: 28.0),
              const SizedBox(width: 8.0),
              ...channelInfoWidgets,
              OutlinedButton(
                onPressed: () {
                  final service = context.read<ChatToSpeechService>();
                  if (service.state == TwitchState.loading) {
                    // Changing channel while Twitch service is still trying to load will cause race condition issues.
                    // Should be easily fixable IF TWITCH_CHAT_SERVICE ISN'T BLACKBOX TO ME.
                    showDialog(
                      context: context,
                      builder: (context) => ContentDialog(
                        title: const Text("Sorry..."),
                        content: const Text(
                            "Cannot change channel while StreamKit is still trying to connect to a channel. Please wait until connection is either complete or fail."),
                        actions: [
                          Button(
                            child: const Text("Ok"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  showTwitchChannelSelection(context);
                },
                child: Text(
                    channels.isEmpty ? "Select channel" : "Change channel"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showTwitchChannelSelection(BuildContext context) {
    showDialog(
        context: context, builder: (context) => TwitchChannelSelectionDialog());
  }
}
