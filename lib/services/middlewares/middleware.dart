import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';

abstract class Middleware {
  Future<Message?> process(Message message);
}
