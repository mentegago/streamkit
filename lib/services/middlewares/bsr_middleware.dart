import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';
import 'package:streamkit_tts/services/middlewares/middleware.dart';
import 'package:streamkit_tts/utils/beat_saver_util.dart';

class BsrMiddleware implements Middleware {
  final Config _config;
  final BeatSaverUtil _beatSaverUtil = BeatSaverUtil();

  BsrMiddleware({required config}) : _config = config;

  @override
  Future<Message?> process(Message message) async {
    if (message is! ChatMessage) return message;
    if (!_config.chatToSpeechConfiguration.readBsr) return message;

    final command = message.rawMessage.toLowerCase().trim().split(' ');
    if (command.length < 2 || command[0] != '!bsr') return message;

    final bsrCode = command[1];
    try {
      final songName = await _beatSaverUtil.getSongName(bsrCode: bsrCode);
      final filteredSongName =
          _config.chatToSpeechConfiguration.readBsrSafely ? "a song" : songName;

      return message.copyWith(
        suggestedSpeechMessage:
            "${message.username.replaceAll("_", " ")} requested $filteredSongName",
        isSuggestedSpeechMessageFinalized: true,
      );
    } catch (_) {
      return null;
    }
  }
}
