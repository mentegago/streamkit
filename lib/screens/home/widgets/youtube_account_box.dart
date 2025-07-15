import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/home/widgets/dialogs/youtube_video_selection_dialog.dart';
import 'package:streamkit_tts/utils/youtube_util.dart';

class YoutubeAccountBox extends HookWidget {
  const YoutubeAccountBox({super.key});

  @override
  Widget build(BuildContext context) {
    final videoId = context.select(
      (Config config) => config.chatToSpeechConfiguration.youtubeVideoId,
    );

    return Row(
      children: [
        const _ProfilePicture(),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                videoId.youtubeVideoId ?? "No video selected",
              ),
              videoId.isNotEmpty
                  ? const Opacity(
                      opacity: 0.5,
                      child: Text("YouTube Live Video"),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const YoutubeVideoSelectionDialog(),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fixedSize: const Size.fromHeight(38),
          ),
          child: Text(
            videoId.isEmpty ? "Select Video" : "Change Video",
          ),
        ),
      ],
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: SvgPicture.asset(
        "assets/images/youtube_icon.svg",
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
