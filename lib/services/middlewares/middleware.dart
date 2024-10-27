import 'package:streamkit_tts/models/messages/message.dart';

abstract class Middleware {
  Future<Message?> process(Message message);
}
