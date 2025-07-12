import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:streamkit_tts/models/config_model.dart';

class TwitchChannelSelectionDialog extends HookWidget {
  const TwitchChannelSelectionDialog({
    super.key,
    this.enableChatReaderWithoutAsking = false,
  });

  final bool enableChatReaderWithoutAsking;

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final defaultValue = config.chatToSpeechConfiguration.channels.join(',');
    final usernameController = useTextEditingController(text: defaultValue);
    final usernameFocusNode = useFocusNode();
    final showUsernameEmptyError = useState(false);

    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        // Set to automatically select the text in the text field when in focus, since it's expected that the user might want to change channel.
        usernameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: usernameController.text.length,
        );
      }
    });

    return ContentDialog(
      title: const Text("Select Channel"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "Enter Twitch channel username",
            child: TextBox(
              placeholder: "",
              controller: usernameController,
              focusNode: usernameFocusNode,
              autofocus: true,
            ),
          ),
          if (showUsernameEmptyError.value)
            Text(
              "Please enter username!",
              style: FluentTheme.of(context)
                  .typography
                  .caption
                  ?.copyWith(color: Colors.red),
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
          child: const Text("Set channel"),
          onPressed: () {
            final usernames = usernameController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toSet();

            if (usernames.isEmpty) {
              showUsernameEmptyError.value = true;
              return;
            }
            config.setChannelUsernames(usernames);
            Navigator.pop(context);

            if (!config.chatToSpeechConfiguration.enabled) {
              if (enableChatReaderWithoutAsking) {
                config.setEnabled(true);
                return;
              }

              showDialog(
                  context: context,
                  builder: (context) => startDialog(context, config));
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
          "Do you want to start reading chats from ${config.chatToSpeechConfiguration.channels.map((e) => '"$e"').join(", ")} channel?\n\nYou can toggle chat reader later."),
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
