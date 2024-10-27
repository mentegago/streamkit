import 'package:streamkit_tts/models/messages/message.dart';

abstract class SourceService {
  Stream<Message> getMessageStream();
  Stream<SourceStatus> getStatusStream();
}

enum SourceStatus { inactive, active }
