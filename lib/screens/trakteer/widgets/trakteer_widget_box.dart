import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:collection/collection.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';

class TrakteerWidgetBox extends StatelessWidget {
  const TrakteerWidgetBox({
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
            child: Text("No widget set."),
          ),
        ];
      } else {
        return [
          Text("Trakteer URL:", style: themeData.typography.bodyStrong),
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
        backgroundColor: const Color.fromARGB(255, 190, 30, 45).toAccentColor(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Image.asset("assets/images/trakteer_icon.png", height: 28),
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
    final defaultValue =
        context.read<Config>().chatToSpeechConfiguration.channels.firstOrNull ??
            "";

    showDialog(
        context: context,
        builder: (context) =>
            TwitchChannelSelectionDialog(defaultValue: defaultValue));
  }
}

class TwitchChannelSelectionDialog extends HookWidget {
  const TwitchChannelSelectionDialog({Key? key, required this.defaultValue})
      : super(key: key);

  final String defaultValue;

  @override
  Widget build(BuildContext context) {
    final usernameController = useTextEditingController(text: defaultValue);
    final usernameFocusNode = useFocusNode();
    final showUsernameEmptyError = useState(false);
    final config = context.read<Config>();

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
          TextBox(
            header: "Enter Twitch channel username",
            placeholder: "",
            controller: usernameController,
            focusNode: usernameFocusNode,
            autofocus: true,
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
            final username = usernameController.text.trim();
            if (username.isEmpty) {
              showUsernameEmptyError.value = true;
              return;
            }
            config.setChannelUsernames({username});
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
