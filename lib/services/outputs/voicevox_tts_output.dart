import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/models/messages/prepared_message.dart';
import 'package:streamkit_tts/services/outputs/output_service.dart';

class VoiceVoxOutputPreparedMessage extends PreparedMessage {
  final File audioFile;
  VoiceVoxOutputPreparedMessage({
    required this.audioFile,
    required super.message,
  });
}

class VoiceVoxOutput implements OutputService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Config _config;
  Directory? _tempAudioDir;

  final _audioPlayTimeout = const Duration(seconds: 30); // In case audio hangs.
  final _audioPrepareTimeout = const Duration(seconds: 10);
  final int _speakerId = 1; // Zundamon voice ID.

  VoiceVoxOutput({required Config config}) : _config = config {
    _audioPlayer.play();

    config.addListener(_handleConfigChange);
    _handleConfigChange();
  }

  void _handleConfigChange() {
    if ((_audioPlayer.volume * 100 - _config.chatToSpeechConfiguration.volume)
            .abs() >
        1) {
      _audioPlayer.setVolume(_config.chatToSpeechConfiguration.volume / 100.0);
    }

    if (!_config.chatToSpeechConfiguration.enabled) {
      _audioPlayer.stop();
    }
  }

  @override
  Future<PreparedMessage> prepareMessage(Message message) async {
    try {
      final String text = message.suggestedSpeechMessage;

      // VoiceVox API endpoints
      const String audioQueryUrl = 'http://127.0.0.1:50021/audio_query';
      const String synthesisUrl = 'http://127.0.0.1:50021/synthesis';

      // Step 1: Get audio query
      final audioQueryResponse = await http
          .post(
            Uri.parse(
              '$audioQueryUrl?text=${Uri.encodeComponent(text)}&speaker=$_speakerId',
            ),
          )
          .timeout(
            _audioPrepareTimeout,
            onTimeout: () => http.Response('', 500),
          );

      if (audioQueryResponse.statusCode != 200) {
        throw 'Failed to get audio query: ${audioQueryResponse.statusCode}';
      }

      final audioQueryJson = audioQueryResponse.body;

      // Step 2: Get synthesized audio
      final synthesisResponse = await http
          .post(
            Uri.parse('$synthesisUrl?speaker=$_speakerId'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: audioQueryJson,
          )
          .timeout(
            _audioPrepareTimeout,
            onTimeout: () => http.Response('', 500),
          );

      if (synthesisResponse.statusCode != 200) {
        throw 'Failed to synthesize audio: ${synthesisResponse.statusCode}';
      }

      // Get the temporary directory
      final Directory tempDir = _tempAudioDir ??
          await getTemporaryDirectory().then((dir) async {
            final directory = Directory(
              Platform.isWindows
                  ? '${dir.path}\\Mentega StreamKit for YouTube'
                  : '${dir.path}/Mentega StreamKit for YouTube',
            );

            if (await directory.exists()) {
              await directory.delete(recursive: true);
            }

            return await directory.create(recursive: true);
          });

      _tempAudioDir = tempDir;

      final String filePath = Platform.isWindows
          ? '${tempDir.path}\\streamkit_${message.id}.wav'
          : '${tempDir.path}/streamkit_${message.id}.wav';
      final File file = File(filePath);

      // Write the audio data to the file
      await file.writeAsBytes(synthesisResponse.bodyBytes);

      return VoiceVoxOutputPreparedMessage(
        audioFile: file,
        message: message,
      );
    } catch (e) {
      throw 'Failed to prepare audio: $e';
    }
  }

  @override
  Future<void> playMessage(PreparedMessage preparedMessage) async {
    try {
      if (preparedMessage is! VoiceVoxOutputPreparedMessage) {
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
          .firstWhere((state) =>
              state == ProcessingState.completed ||
              state == ProcessingState.idle)
          .timeout(_audioPlayTimeout);

      // Making sure that if audio player timed out, stop the audio.
      await _audioPlayer.stop();

      // Delete the audio file after playback
      await cancelPreparedMessage(preparedMessage);
    } catch (e) {
      throw 'Error in playAudio: $e';
    }
  }

  @override
  Future<void> cancelPreparedMessage(PreparedMessage preparedMessage) async {
    if (preparedMessage is! VoiceVoxOutputPreparedMessage) {
      return;
    }
    try {
      await preparedMessage.audioFile.delete();
    } catch (_) {}
  }
}
