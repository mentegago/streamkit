import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/twitch_channel_selection_dialog.dart';

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
      data: FluentThemeData(brightness: Brightness.dark),
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
        context: context,
        builder: (context) => const TwitchChannelSelectionDialog());
  }
}
