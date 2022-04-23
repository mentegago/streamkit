import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/services/chat_to_speech_service.dart';
import 'package:streamkit_tts/services/twitch_chat_service.dart';

class ChatReaderStatus extends HookWidget {
  const ChatReaderStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatToSpeechState = context.watch<ChatToSpeechService>().state;
    final color = chatToSpeechState == TwitchState.active
        ? const Color.fromARGB(255, 0, 255, 0)
        : Colors.red.normal;

    final activeAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 0,
      lowerBound: 0.3,
      upperBound: 1,
    )..repeat(
        reverse: true,
      );

    final inactiveAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 500),
      initialValue: 1,
      lowerBound: 1,
      upperBound: 1,
    )..repeat(
        reverse: true,
      );

    return FadeTransition(
      opacity: chatToSpeechState == TwitchState.active
          ? activeAnimationController
          : inactiveAnimationController,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        width: 18,
        height: 18,
      ),
    );
  }
}
