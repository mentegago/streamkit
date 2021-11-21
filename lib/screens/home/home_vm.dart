import 'package:streamkit/modules/stream_kit_module.dart';
import 'package:streamkit/screens/stream_kit_view_model.dart';

class HomeViewModel extends StreamKitViewModel {
  Stream<ModuleState> chatToSpeechState;

  HomeViewModel({required this.chatToSpeechState});
}
