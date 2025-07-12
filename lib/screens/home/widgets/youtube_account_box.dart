import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
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
              Text(videoId.youtubeVideoId ?? ""),
              const Opacity(
                opacity: 0.5,
                child: Text("YouTube Live Video"),
              ),
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
              builder: (context) => const _VideoSelectionDialog(),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fixedSize: const Size.fromHeight(38),
          ),
          child: const Text("Change Video"),
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

class _VideoSelectionDialog extends HookWidget {
  const _VideoSelectionDialog();

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController(
      text: context.read<Config>().chatToSpeechConfiguration.youtubeVideoId,
    );

    final errorMessage = useState("");
    final focusNode = useFocusNode();

    focus() {
      focusNode.requestFocus();
      textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textController.text.length,
      );
    }

    onSubmitted() {
      if (textController.text.isEmpty ||
          textController.text.youtubeVideoId == null) {
        errorMessage.value = "Enter a valid YouTube Live Video";
        focus();
        return;
      }

      context.read<Config>().setYouTubeVideoId(textController.text);

      Navigator.of(context).pop();
    }

    useEffect(() {
      focus();
      return null;
    }, []);

    return AlertDialog(
      title: const Text("Change Video"),
      content: TextField(
        onSubmitted: (_) {
          onSubmitted();
        },
        decoration: InputDecoration(
          error:
              errorMessage.value.isNotEmpty ? Text(errorMessage.value) : null,
          labelText: "YouTube Live Video",
        ),
        controller: textController,
        focusNode: focusNode,
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: onSubmitted,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
