import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/models/messages/prepared_message.dart';

abstract class OutputService {
  Future<PreparedMessage> prepareMessage(Message message);
  Future<void> cancelPreparedMessage(PreparedMessage preparedMessage);
  Future<void> playMessage(PreparedMessage preparedMessage);
}
