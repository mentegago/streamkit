import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/screens/legacy_home/widgets/dialogs/youtube_video_selection_dialog.dart';
import 'package:streamkit_tts/services/composers/composer_service.dart';

class ToggleChatReaderButton extends StatelessWidget {
  const ToggleChatReaderButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final composer = context.read<ComposerService>();
    final config = context.read<Config>();

    final onPressed = (() {
      if (config.chatToSpeechConfiguration.youtubeVideoId.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => const YoutubeVideoSelectionDialog(
            enableChatReaderWithoutAsking: true,
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

    return StreamBuilder<ComposerStatus>(
      stream: composer.getStatusStream(),
      builder: (context, snapshot) {
        final status = snapshot.data ?? ComposerStatus.inactive;
        switch (status) {
          case ComposerStatus.active:
            return Button(
              onPressed: onPressed,
              style: buttonStyle,
              child: const Text("Stop Chat Reader"),
            );

          case ComposerStatus.inactive:
            return FilledButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: const Text("Start Chat Reader"),
            );

          case ComposerStatus.loading:
            return const Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: ProgressRing(),
            );
        }
      },
    );
  }
}
