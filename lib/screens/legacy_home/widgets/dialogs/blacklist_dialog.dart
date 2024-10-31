import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';

class BlacklistDialog extends HookWidget {
  const BlacklistDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();
    final defaultValue =
        config.chatToSpeechConfiguration.filteredUsernames.join(',');
    final usernameController = useTextEditingController(text: defaultValue);
    final usernameFocusNode = useFocusNode();

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
      title: const Text("User Filter"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label:
                'Enter the usernames of chatters you\'d like StreamKit to ignore, separated by commas.\n\nExample: streamelements,streamlabs,nightbot',
            child: TextBox(
              placeholder: "",
              controller: usernameController,
              focusNode: usernameFocusNode,
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
          child: const Text("Update blacklist"),
          onPressed: () {
            final usernames = usernameController.text
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty)
                .toSet();

            config.setUserFilter(
              usernames: usernames,
              isWhitelistingFilter: false,
            );

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
