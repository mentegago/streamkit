import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/services/interfaces/text_to_speech_service.dart';

abstract class OutputService {
  Future<PreparedMessage> prepareAudio(Message message);
  Future<void> playAudio(PreparedMessage preparedMessage);
}

class GoogleTtsOutputPreparedMessage extends PreparedMessage {
  final File audioFile;
  GoogleTtsOutputPreparedMessage(
      {required this.audioFile, required super.message});
}

class GoogleTtsOutput implements OutputService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  GoogleTtsOutput() {
    _audioPlayer.processingStateStream.listen(
      (event) {
        print("Event: " + event.toString());
      },
    );

    _audioPlayer.play();
  }

  @override
  Future<PreparedMessage> prepareAudio(Message message) async {
    try {
      final String langCode = message.language.google;
      final String text = Uri.encodeComponent(message.suggestedSpeechMessage);

      // Construct the Google Translate TTS URL
      // Note: This is an unofficial endpoint and may not be reliable for production use.
      final String url =
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=$langCode&q=$text';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0', // Google requires a user-agent header
        },
      );

      if (response.statusCode == 200) {
        // Get the temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/${message.id}.mp3';
        final File file = File(filePath);

        // Write the audio data to the file
        await file.writeAsBytes(response.bodyBytes);

        return GoogleTtsOutputPreparedMessage(
            audioFile: file, message: message);
      } else {
        print('Failed to download audio: ${response.statusCode}');
        throw 'Failed to download audio';
      }
    } catch (e) {
      print('Error in prepareAudio: $e');
      throw 'Failed to prepare audio';
    }
  }

  @override
  Future<void> playAudio(PreparedMessage preparedMessage) async {
    try {
      if (preparedMessage is! GoogleTtsOutputPreparedMessage) {
        return;
      }
      final file = preparedMessage.audioFile;

      if (!await file.exists()) {
        throw Exception('Audio file does not exist.');
      }

      await _audioPlayer.stop();

      // Set the audio source
      await _audioPlayer.setFilePath(file.path);

      // Play the audio
      await _audioPlayer.play();

      // Wait until playback is complete
      await _audioPlayer.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed)
          .timeout(const Duration(seconds: 5));

      // Delete the audio file after playback
      await file.delete();
    } catch (e) {
      print('Error in playAudio: $e');
      // Optionally, rethrow or handle the error as needed
      throw e;
    }
  }
}
