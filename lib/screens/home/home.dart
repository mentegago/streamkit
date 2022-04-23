import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/screens/home/widgets/chat_reader_status_info.dart';

import 'package:streamkit_tts/screens/home/widgets/config_groups/bs_config_group.dart';
import 'package:streamkit_tts/screens/home/widgets/config_groups/languages_config_group.dart';
import 'package:streamkit_tts/screens/home/widgets/config_groups/tts_config_group.dart';
import 'package:streamkit_tts/screens/home/widgets/footer/toggle_chat_reader_button.dart';
import 'package:streamkit_tts/screens/home/widgets/twitch_channel_box.dart';
import 'package:streamkit_tts/screens/home/widgets/footer/volume_control.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() => _errorStateEffect(context));
    useEffect(() => _versionCheckEffect(context));

    return ScaffoldPage(
      header: const PageHeader(
        title: Text("StreamKit Chat Reader"),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TwitchChannelBox(),
                const SizedBox(height: 32.0),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  spacing: 48.0,
                  runSpacing: 32.0,
                  children: const [
                    TtsConfigGroup(),
                    LanguagesConfigGroup(),
                    BeatSaberConfigGroup(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            VolumeControl(),
            ToggleChatReaderButton(),
          ],
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

  Function()? _versionCheckEffect(BuildContext context) {
    final versionCheckService = context.read<VersionCheckService>();

    versionCheckService.addListener(() {
      final status = versionCheckService.status;
      String? updateMessage;
      String? updateTitle;

      switch (status.state) {
        case VersionState.loading:
        case VersionState.error:
        case VersionState.upToDate:
          break;
        case VersionState.outdated:
          updateTitle = "Out of date";
          updateMessage =
              "StreamKit is out of date. Please update to the latest version (${status.latestVersion}).";
          break;
        case VersionState.beta:
          updateTitle = "Prerelease Version";
          updateMessage =
              "You are running prerelease version of StreamKit. Some features may not work properly.";
          break;
      }

      if (updateTitle != null && updateMessage != null) {
        showDialog(
          context: context,
          builder: (context) => ContentDialog(
            title: Text(updateTitle ?? ""),
            content: Text(updateMessage ?? ""),
            actions: [
              Button(
                child: const Text("Later"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: const Text("Download latest stable"),
                onPressed: () {
                  launchUrlString(versionCheckService.downloadUrl);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    });

    return () {
      versionCheckService.removeListener(() {});
    };
  }
}
