import 'dart:async';
import 'package:audio_service/audio_service.dart';

class AppAudioHandlerService extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  Function()? onStop;
  Function()? onPlay;

  void setNotification({
    required bool isPlaying,
    String? username,
  }) {
    if (isPlaying) {
      mediaItem.add(
        MediaItem(
          id: "id",
          title: "StreamKit",
          artist: username ?? "Account",
        ),
      );

      playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.ready,
          playing: true,
          repeatMode: AudioServiceRepeatMode.one,
        ),
      );
    } else {
      playbackState.add(
        PlaybackState(
          playing: false,
          processingState: AudioProcessingState.idle,
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    if (onPlay != null) {
      onPlay!();
    }
    return;
  }

  @override
  Future<void> pause() async {
    if (onStop != null) {
      onStop!();
    }
    return super.pause();
  }

  @override
  Future<void> stop() {
    if (onStop != null) {
      onStop!();
    }
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    return;
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    return;
  }
}
