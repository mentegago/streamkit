import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/composer_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';

class ChatReaderStatus extends HookWidget {
  const ChatReaderStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final composer = context.read<ComposerService>();
    return StreamBuilder<ComposerStatus>(
      stream: composer.getStatusStream(),
      builder: (context, snapshot) => Container(
        decoration: BoxDecoration(
          color: snapshot.data == ComposerStatus.active
              ? Color.fromARGB(255, 0, 255, 0)
              : Colors.red.normal,
          shape: BoxShape.circle,
        ),
        width: 18,
        height: 18,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final chatToSpeechState =
  //       context.select((ChatToSpeechService service) => service.state);
  //   final color = chatToSpeechState == TwitchState.active
  //       ? const Color.fromARGB(255, 0, 255, 0)
  //       : Colors.red.normal;

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: color,
  //       shape: BoxShape.circle,
  //     ),
  //     width: 18,
  //     height: 18,
  //   );
  // }
}
