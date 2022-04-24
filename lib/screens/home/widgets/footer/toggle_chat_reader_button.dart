import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';

class ToggleChatReaderButton extends StatelessWidget {
  const ToggleChatReaderButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = context.read<Config>();

    final enabled = context
        .select((Config config) => config.chatToSpeechConfiguration.enabled);
    final state =
        context.select((ChatToSpeechService service) => service.state);

    final onPressed = (() {
      if (config.chatToSpeechConfiguration.channels.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text("No channel"),
            content: const Text(
                "Please select a channel for StreamKit to read from!"),
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
      config.setEnabled(!config.chatToSpeechConfiguration.enabled);
    });

    final buttonStyle = ButtonStyle(
      padding: ButtonState.all(
        const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 10.0,
        ),
      ),
    );

    if (enabled && state == TwitchState.active) {
      return Button(
        child: const Text("Stop Chat Reader"),
        onPressed: onPressed,
        style: buttonStyle,
      );
    } else if (!enabled || state == TwitchState.inactive) {
      return FilledButton(
        child: const Text("Start Chat Reader"),
        onPressed: onPressed,
        style: buttonStyle,
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(right: 50.0),
        child: ProgressRing(),
      );
    }
  }
}
