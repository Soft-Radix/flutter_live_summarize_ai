import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:flutter_live_summarize_ai/core/helpers/permission_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Provider class for audio recording functionality
class AudioProvider {
  final _audioRecorder = AudioRecorder();
  String? _currentPath;
  bool _isRecording = false;

  /// Check if currently recording audio
  bool get isRecording => _isRecording;

  /// Get the path of the currently recorded audio file
  String? get currentPath => _currentPath;

  /// Start recording audio
  /// Returns the path where the audio is being recorded
  Future<String> startRecording() async {
    try {
      // Check for microphone permission
      final hasPermission = await PermissionHelper.checkAndRequestMicrophonePermission();
      if (!hasPermission) {
        throw const PermissionException(
          message: 'Microphone permission denied',
        );
      }

      // Get the directory for storing audio files
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final path = '${appDir.path}/recording_$timestamp.m4a';

      // Configure the audio recorder
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _currentPath = path;
      _isRecording = true;
      return path;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      throw RecordingException(
        message: 'Failed to start recording',
        details: e,
      );
    }
  }

  /// Stop the current recording
  /// Returns the path of the recorded audio file
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return _currentPath;

      await _audioRecorder.stop();
      _isRecording = false;
      return _currentPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      throw RecordingException(
        message: 'Failed to stop recording',
        details: e,
      );
    }
  }

  /// Pause the current recording
  Future<void> pauseRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.pause();
      }
    } catch (e) {
      debugPrint('Error pausing recording: $e');
      throw RecordingException(
        message: 'Failed to pause recording',
        details: e,
      );
    }
  }

  /// Resume a paused recording
  Future<void> resumeRecording() async {
    try {
      await _audioRecorder.resume();
    } catch (e) {
      debugPrint('Error resuming recording: $e');
      throw RecordingException(
        message: 'Failed to resume recording',
        details: e,
      );
    }
  }

  /// Dispose the audio recorder
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }

  /// Delete a recorded audio file
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting recording: $e');
      throw RecordingException(
        message: 'Failed to delete recording',
        details: e,
      );
    }
  }
}
