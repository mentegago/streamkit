import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';

abstract class SourceService {
  Stream<Message> getMessageStream();
  Stream<SourceStatus> getStatusStream();
}

enum SourceStatus { inactive, active }
