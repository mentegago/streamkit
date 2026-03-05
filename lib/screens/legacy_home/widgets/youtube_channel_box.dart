import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/legacy_home/widgets/dialogs/youtube_video_selection_dialog.dart';
import 'package:streamkit_tts/utils/youtube_util.dart';

class YouTubeChannelBox extends StatelessWidget {
  const YouTubeChannelBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = FluentTheme.of(context);
    final videoId = context.select(
        (Config config) => config.chatToSpeechConfiguration.youtubeVideoId);

    final List<Widget> channelInfoWidgets = (() {
      if (videoId.isEmpty) {
        return [
          const Expanded(
            child: Text("No youtube live video ID set."),
          ),
        ];
      } else {
        return [
          Text(
            "YouTube Live Video ID:",
            style: themeData.typography.bodyStrong,
          ),
          const SizedBox(width: 4.0),
          Expanded(child: Text(videoId.youtubeVideoId ?? "")),
        ];
      }
    })();

    return FluentTheme(
      data: FluentThemeData(brightness: Brightness.dark),
      child: Card(
        backgroundColor: const Color.fromARGB(255, 200, 0, 0).toAccentColor(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/images/youtube_icon.svg",
                height: 28.0,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: 8.0),
              ...channelInfoWidgets,
              OutlinedButton(
                onPressed: () {
                  showVideoIdSelection(context);
                },
                child:
                    Text(videoId.isEmpty ? "Set video ID" : "Update video ID"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showVideoIdSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const YoutubeVideoSelectionDialog(),
    );
  }
}
