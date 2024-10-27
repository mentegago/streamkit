import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:streamkit_tts/models/config_model.dart';

class YoutubeVideoSelectionDialog extends HookWidget {
  const YoutubeVideoSelectionDialog({
    super.key,
    this.enableChatReaderWithoutAsking = false,
  });

  final bool enableChatReaderWithoutAsking;

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final defaultValue = config.chatToSpeechConfiguration.youtubeVideoId;
    final videoIdController = useTextEditingController(text: defaultValue);
    final videoIdFocusNode = useFocusNode();

    videoIdFocusNode.addListener(() {
      if (videoIdFocusNode.hasFocus) {
        // Set to automatically select the text in the text field when in focus, since it's expected that the user might want to change channel.
        videoIdController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: videoIdController.text.length,
        );
      }
    });

    return ContentDialog(
      title: const Text("Enter Video ID"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "Enter YouTube Video ID",
            child: TextBox(
              placeholder: "",
              controller: videoIdController,
              focusNode: videoIdFocusNode,
              autofocus: true,
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FilledButton(
          child: const Text("Set video ID"),
          onPressed: () {
            final videoId = videoIdController.text.trim();

            if (videoId.isEmpty) config.setEnabled(false);
            config.setYouTubeVideoId(videoId);
            Navigator.pop(context);

            if (!config.chatToSpeechConfiguration.enabled &&
                videoId.isNotEmpty) {
              if (enableChatReaderWithoutAsking) {
                config.setEnabled(true);
                return;
              }

              showDialog(
                context: context,
                builder: (context) => startDialog(context, config),
              );
            }
          },
        ),
      ],
    );
  }

  Widget startDialog(BuildContext context, Config config) {
    return ContentDialog(
      title: const Text("Start Chat Reader?"),
      content: Text(
          "Do you want to start reading chats from ${config.chatToSpeechConfiguration.youtubeVideoId}?\n\nYou can toggle chat reader later."),
      actions: [
        Button(
          child: const Text("Not now"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FilledButton(
          child: const Text("Start Chat Reader"),
          onPressed: () {
            config.setEnabled(true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
