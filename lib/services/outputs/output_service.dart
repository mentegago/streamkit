import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';

abstract class OutputService {
  Future<PreparedMessage> prepareAudio(Message message);
  Future<void> cancelAudio(PreparedMessage preparedMessage);
  Future<void> playAudio(PreparedMessage preparedMessage);
}
