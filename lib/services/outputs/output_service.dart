import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/models/messages/prepared_message.dart';

abstract class OutputService {
  Future<PreparedMessage> prepareAudio(Message message);
  Future<void> cancelAudio(PreparedMessage preparedMessage);
  Future<void> playAudio(PreparedMessage preparedMessage);
}
