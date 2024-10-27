import 'package:streamkit_tts/models/messages/message.dart';

class PreparedMessage {
  final Message message;
  final double? duration;

  PreparedMessage({
    required this.message,
    this.duration,
  });
}
