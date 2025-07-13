import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';

class ChannelSelectionDialog extends HookWidget {
  const ChannelSelectionDialog({
    super.key,
    this.onSelected,
    this.onCancelled,
  });

  final void Function(String channelName)? onSelected;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context) {
    final initialChannel =
        context.read<Config>().chatToSpeechConfiguration.channels.firstOrNull;

    final textController = useTextEditingController(
      text: initialChannel ?? "",
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
      if (textController.text.isEmpty) {
        errorMessage.value = "Enter a valid channel name";
        focus();
        return;
      }

      context.read<Config>().setChannelUsernames({
        textController.text,
      });

      Navigator.of(context).pop();
      onSelected?.call(textController.text);
    }

    onCancelled() {
      Navigator.of(context).pop();
      this.onCancelled?.call();
    }

    useEffect(() {
      focus();
      return null;
    }, []);

    return AlertDialog(
      title: initialChannel == null
          ? const Text("Select Channel")
          : const Text("Change Channel"),
      content: TextField(
        onSubmitted: (_) {
          onSubmitted();
        },
        decoration: InputDecoration(
          error:
              errorMessage.value.isNotEmpty ? Text(errorMessage.value) : null,
          labelText: "Twitch channel name",
        ),
        controller: textController,
        focusNode: focusNode,
      ),
      actions: [
        TextButton(
          onPressed: onCancelled,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onSubmitted,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
