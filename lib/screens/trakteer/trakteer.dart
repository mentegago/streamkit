import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/chat_reader_status_info.dart';

import 'package:streamkit_tts/screens/home/widgets/footer/toggle_chat_reader_button.dart';
import 'package:streamkit_tts/screens/home/widgets/footer/volume_control.dart';
import 'package:streamkit_tts/screens/trakteer/widgets/trakteer_widget_box.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Trakteer extends HookWidget {
  const Trakteer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() => _errorStateEffect(context));

    return FluentTheme(
      data: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: const Color.fromARGB(255, 190, 30, 45).toAccentColor(),
      ),
      child: ScaffoldPage(
        header: const PageHeader(
          title: Text("Trakteer Donation Reader"),
          commandBar: ChatReaderStatus(),
        ),
        content: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 0.0,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Scrollbar(
              controller: scrollController,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TrakteerWidgetBox(),
                  SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
        bottomBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VolumeControl(),
              ToggleChatReaderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Function()? _errorStateEffect(BuildContext context) {
    final errorStream = context.read<ChatToSpeechService>().errorStream;
    final subscription = errorStream.listen((error) {
      switch (error) {
        case TwitchError.timeout:
          showDialog(
            context: context,
            builder: (context) => ContentDialog(
              title: const Text("Timeout"),
              content: const Text(
                  "Fail to connect to channel. Please make sure the username is correct."),
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
      }
    });

    return subscription.cancel;
  }
}
