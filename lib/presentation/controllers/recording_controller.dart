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
      debugPrint('DEBUG: RecordingController - Starting recording with title: $title');

      // Set loading state
      _summaryResponse.value = ApiResponse.loading();
      _statusMessage.value = AppStrings.recording;
      debugPrint('DEBUG: Set to loading state with status message: ${_statusMessage.value}');

      // Create recording session
      debugPrint('DEBUG: Creating recording session through repository');
      final response = await _summaryRepository.createRecordingSession(title);
      debugPrint('DEBUG: Repository response received, isCompleted: ${response.isCompleted}');

      if (response.isCompleted) {
        _isRecording.value = true;
        _summaryResponse.value = response;
        debugPrint('DEBUG: Recording started successfully, isRecording: ${_isRecording.value}');
      } else {
        _statusMessage.value = response.message ?? AppStrings.errorRecording;
        _summaryResponse.value = response;
        debugPrint('DEBUG: Recording failed to start, status message: ${_statusMessage.value}');
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: Error starting recording: $e');
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
        debugPrint('DEBUG: Not recording or no current summary, cannot stop');
        return;
      }

      debugPrint('DEBUG: RecordingController - Stopping recording');
      _statusMessage.value = AppStrings.processingAudio;
      debugPrint('DEBUG: Set status message to: ${_statusMessage.value}');

      debugPrint('DEBUG: Stopping recording session through repository');
      final response = await _summaryRepository.stopRecordingSession(currentSummary!);
      debugPrint('DEBUG: Repository stop response received, isCompleted: ${response.isCompleted}');

      _isRecording.value = false;
      _summaryResponse.value = response;

      if (response.isCompleted) {
        debugPrint('DEBUG: Processing audio completed, beginning transcription');
        _statusMessage.value = AppStrings.transcribing;

        // In a real app, this is where you would call the speech-to-text service
        // For now, we'll simulate the process with a delay
        debugPrint('DEBUG: Simulating transcription with delay');
        await Future.delayed(const Duration(seconds: 2));

        // Update status to summarizing
        _statusMessage.value = AppStrings.summarizing;
        debugPrint('DEBUG: Set status message to: ${_statusMessage.value}');

        // Simulate summarization with a delay
        debugPrint('DEBUG: Simulating summarization with delay');
        await Future.delayed(const Duration(seconds: 2));

        // Create a mock summary
        debugPrint('DEBUG: Creating mock summary from recorded audio');
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
        debugPrint('DEBUG: Saving completed summary to repository');
        await _summaryRepository.saveSummary(summary);
        debugPrint('DEBUG: Summary saved successfully');

        // Update response with completed summary
        _summaryResponse.value = ApiResponse.completed(summary);
        _statusMessage.value = '';
        debugPrint('DEBUG: Summary processing complete');
      } else {
        _statusMessage.value = response.message ?? AppStrings.errorRecording;
        debugPrint('DEBUG: Recording stop failed, status message: ${_statusMessage.value}');
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: Error stopping recording: $e');
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
