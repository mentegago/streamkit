import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/utils/youtube_util.dart';

class YoutubeVideoSelectionDialog extends HookWidget {
  const YoutubeVideoSelectionDialog({
    super.key,
    this.onSelected,
    this.onCancelled,
  });

  final void Function(String videoId)? onSelected;
  final VoidCallback? onCancelled;

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
      onSelected?.call(textController.text);
    }

    onCancelledLocal() {
      Navigator.of(context).pop();
      onCancelled?.call();
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
          onPressed: onCancelledLocal,
        ),
        TextButton(
          onPressed: onSubmitted,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
