import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:flutter_live_summarize_ai/core/helpers/api_response.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:get/get.dart';

/// Controller for managing recording functionality
class RecordingController extends GetxController {
  final SummaryRepository _summaryRepository;

  // Observable variables
  final Rx<ApiResponse<SummaryModel>> _summaryResponse = ApiResponse<SummaryModel>.idle().obs;
  final RxBool _isRecording = false.obs;
  final RxString _statusMessage = ''.obs;

  /// Constructor
  RecordingController({
    required SummaryRepository summaryRepository,
  }) : _summaryRepository = summaryRepository;

  /// Getter for summary response
  ApiResponse<SummaryModel> get summaryResponse => _summaryResponse.value;

  /// Getter for recording status
  bool get isRecording => _isRecording.value;

  /// Getter for status message
  String get statusMessage => _statusMessage.value;

  /// Getter for current summary
  SummaryModel? get currentSummary => _summaryResponse.value.data;

  /// Start recording with the given title
  Future<void> startRecording(String title) async {
    try {
      // Set loading state
      _summaryResponse.value = ApiResponse.loading();
      _statusMessage.value = AppStrings.recording;

      // Create recording session
      final response = await _summaryRepository.createRecordingSession(title);

      if (response.isCompleted) {
        _isRecording.value = true;
        _summaryResponse.value = response;
      } else {
        _statusMessage.value = response.message ?? AppStrings.errorRecording;
        _summaryResponse.value = response;
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _statusMessage.value = e is AppException ? e.message : AppStrings.errorRecording;

      _summaryResponse.value = ApiResponse.error(
        _statusMessage.value,
        e is Exception ? e : null,
      );
    }
  }

  /// Stop the current recording
  Future<void> stopRecording() async {
    try {
      if (!_isRecording.value || currentSummary == null) {
        return;
      }

      _statusMessage.value = AppStrings.processingAudio;

      final response = await _summaryRepository.stopRecordingSession(currentSummary!);

      _isRecording.value = false;
      _summaryResponse.value = response;

      if (response.isCompleted) {
        _statusMessage.value = AppStrings.transcribing;

        // In a real app, this is where you would call the speech-to-text service
        // For now, we'll simulate the process with a delay
        await Future.delayed(const Duration(seconds: 2));

        // Update status to summarizing
        _statusMessage.value = AppStrings.summarizing;

        // Simulate summarization with a delay
        await Future.delayed(const Duration(seconds: 2));

        // Create a mock summary
        final summary = currentSummary!.copyWith(
          transcription: 'This is a simulated transcription of the recorded audio.',
          keyPoints: [
            'First key point from the simulated summary.',
            'Second key point with some additional context.',
            'Third key point that highlights important information.',
          ],
          status: SummaryStatus.completed,
        );

        // Save the summary
        await _summaryRepository.saveSummary(summary);

        // Update response with completed summary
        _summaryResponse.value = ApiResponse.completed(summary);
        _statusMessage.value = '';
      } else {
        _statusMessage.value = response.message ?? AppStrings.errorRecording;
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording.value = false;
      _statusMessage.value = e is AppException ? e.message : AppStrings.errorRecording;

      _summaryResponse.value = ApiResponse.error(
        _statusMessage.value,
        e is Exception ? e : null,
      );
    }
  }

  /// Reset the controller state
  void reset() {
    _summaryResponse.value = ApiResponse.idle();
    _isRecording.value = false;
    _statusMessage.value = '';
  }
}
