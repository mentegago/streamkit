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
import 'package:streamkit_tts/services/composers/composer_service.dart';
import 'package:streamkit_tts/services/version_check_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeNewVersionWidget extends HookWidget {
  const HomeNewVersionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final versionStatus =
        context.select((VersionCheckService service) => service.status);

    final shouldShow = versionStatus.state == VersionState.outdated ||
        versionStatus.state == VersionState.beta ||
        versionStatus.announcement != null;

    if (!shouldShow) {
      return const SizedBox();
    }

    final color = versionStatus.state != VersionState.upToDate
        ? Colors.red
        : Colors.green;

    final message = versionStatus.announcement ??
        (versionStatus.state == VersionState.outdated
            ? "StreamKit ${versionStatus.latestVersion} is now available!"
            : "You're running prerelease version!");

    final actionUrl =
        versionStatus.announcementUrl ?? versionStatus.downloadUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            launchUrlString(actionUrl, mode: LaunchMode.inAppWebView);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            color: color,
            child: Text(message, style: const TextStyle(fontSize: 12.0)),
          ),
        ),
      ),
    );
  }
}

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    useEffect(() => _errorStateEffect(context));
    // useEffect(() => _chatToSpeechErrorEffect(context));

    return ScaffoldPage(
      header: const PageHeader(
        title: Text("StreamKit Chat Reader"),
        commandBar: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: [
            HomeNewVersionWidget(),
            ChatReaderStatus(),
          ],
        ),
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
                TwitchChannelBox(),
                SizedBox(height: 32.0),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  spacing: 48.0,
                  runSpacing: 32.0,
                  children: [
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VolumeControl(),
            ToggleChatReaderButton(),
          ],
        ),
      ),
    );
  }

  Function()? _errorStateEffect(BuildContext context) {
    final errorStream = context.read<ComposerService>().getErrorStream();
    final subscription = errorStream.listen((errorMessage) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: const Text("Timeout"),
          content: Text(
            errorMessage,
          ),
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
    });

    return subscription.cancel;
  }
}
