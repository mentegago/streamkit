import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/enums/languages_enum.dart';
import 'package:streamkit_tts/models/messages/message.dart';
import 'package:streamkit_tts/models/messages/prepared_message.dart';
import 'package:streamkit_tts/services/outputs/output_service.dart';

class GoogleTtsOutputPreparedMessage extends PreparedMessage {
  final File audioFile;
  GoogleTtsOutputPreparedMessage(
      {required this.audioFile, required super.message});
}

class GoogleTtsOutput implements OutputService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Config _config;
  Directory? _tempAudioDir;

  final _maxMessageLength = 120; // Important for Google TTS limit.
  final _audioPlayTimeout = const Duration(seconds: 30); // In case audio hangs.
  final _audioPrepareTimeout = const Duration(seconds: 10);

  GoogleTtsOutput({required Config config}) : _config = config {
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
      final String langCode = (message.language ?? Language.english).google;
      final String text = Uri.encodeComponent(
        message.suggestedSpeechMessage.substring(
          0,
          min(
            message.suggestedSpeechMessage.length,
            _maxMessageLength,
          ),
        ),
      );
      final String url =
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=$langCode&q=$text';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0', // Google requires a user-agent header
        },
      ).timeout(
        _audioPrepareTimeout,
        onTimeout: () => http.Response("", 500),
      );

      if (response.statusCode == 200) {
        // Get the temporary directory
        final Directory tempDir = _tempAudioDir ??
            await getTemporaryDirectory().then((dir) async {
              final directory = Directory(
                Platform.isWindows
                    ? '${dir.path}\\Mentega StreamKit'
                    : '${dir.path}/Mentega StreamKit',
              );

              if (await directory.exists()) {
                await directory.delete(recursive: true);
              }

              return await directory.create(recursive: true);
            });

        _tempAudioDir = tempDir;

        final String filePath = Platform.isWindows
            ? '${tempDir.path}\\streamkit_${message.id}.mp3'
            : '${tempDir.path}/streamkit_${message.id}.mp3';
        final File file = File(filePath);

        // Write the audio data to the file
        await file.writeAsBytes(response.bodyBytes);

        return GoogleTtsOutputPreparedMessage(
          audioFile: file,
          message: message,
        );
      } else {
        throw 'Failed to download audio: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Failed to prepare audio: $e';
    }
  }

  @override
  Future<void> playMessage(PreparedMessage preparedMessage) async {
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
    if (preparedMessage is! GoogleTtsOutputPreparedMessage) {
      return;
    }
    try {
      await preparedMessage.audioFile.delete();
    } catch (_) {}
  }
}
