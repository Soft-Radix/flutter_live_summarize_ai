import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Provider class for audio playback functionality
class AudioPlayerProvider {
  final _audioPlayer = AudioPlayer();

  /// Current playback state
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// Current playback progress (0.0 to 1.0)
  final ValueNotifier<double> progress = ValueNotifier<double>(0.0);

  /// Current position in the audio
  final ValueNotifier<Duration> position = ValueNotifier<Duration>(Duration.zero);

  /// Total duration of the audio
  final ValueNotifier<Duration> duration = ValueNotifier<Duration>(Duration.zero);

  /// Constructor for AudioPlayerProvider
  AudioPlayerProvider() {
    _setupListeners();
  }

  /// Initialize listeners for player state changes
  void _setupListeners() {
    // Listen for player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final isCurrentlyPlaying = playerState.playing;
      final processingState = playerState.processingState;

      // Update isPlaying state
      isPlaying.value = isCurrentlyPlaying && processingState != ProcessingState.completed;

      debugPrint(
          'DEBUG: AudioPlayerProvider - Player state changed: playing=${isPlaying.value}, state=${processingState.name}');

      // If playback completed, reset position
      if (processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
      }
    });

    // Listen for position changes
    _audioPlayer.positionStream.listen((newPosition) {
      position.value = newPosition;

      // Calculate progress
      if (duration.value.inMilliseconds > 0) {
        progress.value = newPosition.inMilliseconds / duration.value.inMilliseconds;
      }
    });

    // Listen for duration changes
    _audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
      }
    });
  }

  /// Load audio from a file path
  Future<void> loadAudio(String filePath) async {
    try {
      debugPrint('DEBUG: AudioPlayerProvider - Loading audio from $filePath');

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('DEBUG ERROR: AudioPlayerProvider - Audio file not found: $filePath');
        throw Exception('Audio file not found');
      }

      // Stop any current playback
      await _audioPlayer.stop();

      // Load the audio file
      await _audioPlayer.setFilePath(filePath);

      debugPrint(
          'DEBUG: AudioPlayerProvider - Audio loaded successfully, duration: ${duration.value}');
    } catch (e) {
      debugPrint('DEBUG ERROR: AudioPlayerProvider - Error loading audio: $e');
      rethrow;
    }
  }

  /// Play the loaded audio
  Future<void> play() async {
    try {
      debugPrint('DEBUG: AudioPlayerProvider - Starting playback');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('DEBUG ERROR: AudioPlayerProvider - Error playing audio: $e');
      rethrow;
    }
  }

  /// Pause the currently playing audio
  Future<void> pause() async {
    try {
      debugPrint('DEBUG: AudioPlayerProvider - Pausing playback');
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('DEBUG ERROR: AudioPlayerProvider - Error pausing audio: $e');
      rethrow;
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      debugPrint('DEBUG: AudioPlayerProvider - Stopping playback');
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('DEBUG ERROR: AudioPlayerProvider - Error stopping audio: $e');
      rethrow;
    }
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    try {
      debugPrint('DEBUG: AudioPlayerProvider - Seeking to position: $position');
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('DEBUG ERROR: AudioPlayerProvider - Error seeking audio: $e');
      rethrow;
    }
  }

  /// Seek by percentage (0.0 to 1.0)
  Future<void> seekByPercentage(double percentage) async {
    if (duration.value.inMilliseconds > 0) {
      final newPosition = Duration(
        milliseconds: (percentage * duration.value.inMilliseconds).round(),
      );
      await seekTo(newPosition);
    }
  }

  /// Toggle play/pause state
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      await play();
    }
  }

  /// Format duration as mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  /// Dispose the audio player
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
