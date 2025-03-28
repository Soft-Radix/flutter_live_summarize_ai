import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:flutter_live_summarize_ai/core/helpers/api_response.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/data/services/gemini_service.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:get/get.dart';

/// Controller for managing recording functionality
class RecordingController extends GetxController {
  final SummaryRepository _summaryRepository;
  final GeminiService _geminiService;

  // Flag to determine if we use real AI data
  final bool _useRealAI = true;

  // Observable variables
  final Rx<ApiResponse<SummaryModel>> _summaryResponse = ApiResponse<SummaryModel>.idle().obs;
  final RxBool _isRecording = false.obs;
  final RxString _statusMessage = ''.obs;
  final RxInt _recordingDuration = 0.obs; // Duration in seconds
  Timer? _recordingTimer;

  /// Constructor
  RecordingController({
    required SummaryRepository summaryRepository,
    required GeminiService geminiService,
  })  : _summaryRepository = summaryRepository,
        _geminiService = geminiService;

  /// Getter for summary response
  ApiResponse<SummaryModel> get summaryResponse => _summaryResponse.value;

  /// Getter for recording status
  bool get isRecording => _isRecording.value;

  /// Getter for status message
  String get statusMessage => _statusMessage.value;

  /// Getter for recording duration in seconds
  int get recordingDurationSeconds => _recordingDuration.value;

  /// Getter for formatted recording duration (mm:ss)
  String get formattedDuration {
    final minutes = (_recordingDuration.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordingDuration.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Getter for current summary
  SummaryModel? get currentSummary => _summaryResponse.value.data;

  @override
  void onClose() {
    _recordingTimer?.cancel();
    super.onClose();
  }

  /// Start recording with the given title
  Future<void> startRecording(String title) async {
    try {
      // Validate input
      if (title.isEmpty) {
        debugPrint('DEBUG ERROR: Empty title provided');
        _statusMessage.value = 'Please enter a title for the recording';
        _summaryResponse.value = ApiResponse.error(
          _statusMessage.value,
          Exception('Empty title'),
        );
        return;
      }

      debugPrint('DEBUG: RecordingController - Starting recording with title: $title');

      // Reset recording duration
      _recordingDuration.value = 0;

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

        // Start timer to track recording duration
        _startRecordingTimer();
      } else {
        _statusMessage.value = response.message ?? AppStrings.errorRecording;
        _summaryResponse.value = response;
        debugPrint('DEBUG: Recording failed to start, status message: ${_statusMessage.value}');
      }
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: Error starting recording: $e');
      debugPrint('DEBUG ERROR: Stack trace: $stackTrace');
      _statusMessage.value = e is AppException ? e.message : AppStrings.errorRecording;

      _summaryResponse.value = ApiResponse.error(
        _statusMessage.value,
        e is Exception ? e : null,
      );
    }
  }

  /// Start a timer to track recording duration
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration.value++;
    });
  }

  /// Stop the current recording
  Future<void> stopRecording() async {
    try {
      if (!_isRecording.value || currentSummary == null) {
        debugPrint('DEBUG: Not recording or no current summary, cannot stop');
        _statusMessage.value = 'No active recording to stop';
        _summaryResponse.value = ApiResponse.error(
          _statusMessage.value,
          Exception('No active recording'),
        );
        return;
      }

      // Stop the recording timer
      _recordingTimer?.cancel();
      _recordingTimer = null;

      debugPrint('DEBUG: RecordingController - Stopping recording');
      _statusMessage.value = AppStrings.processingAudio;
      debugPrint('DEBUG: Set status message to: ${_statusMessage.value}');

      debugPrint(
          'DEBUG: Stopping recording session through repository, summary ID: ${currentSummary!.id}');
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

        SummaryModel summary;

        // Generate a simulated transcription based on the title
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final simTranscript = _generateSimulatedTranscription(currentSummary!.title, timestamp);

        if (_useRealAI) {
          // Use Gemini AI to generate the summary
          debugPrint('DEBUG: Using Gemini AI to generate summary from transcription');

          try {
            // Get AI-generated key points based on the transcript
            final keyPoints = await _geminiService.generateSummaryFromTranscription(
                simTranscript, currentSummary!.title);

            debugPrint('DEBUG: Received ${keyPoints.length} key points from Gemini AI');

            // Create the summary with AI-generated key points
            summary = currentSummary!.copyWith(
              transcription: simTranscript,
              keyPoints: keyPoints,
              status: SummaryStatus.completed,
            );
          } catch (e) {
            debugPrint('DEBUG ERROR: Failed to generate AI summary: $e');
            // Fallback to dynamic key points if AI fails
            summary = _createDynamicSummary(simTranscript);
          }
        } else {
          // Create a summary with dynamic key points (non-AI)
          summary = _createDynamicSummary(simTranscript);
        }

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
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: Error stopping recording: $e');
      debugPrint('DEBUG ERROR: Stack trace: $stackTrace');
      _isRecording.value = false;
      _statusMessage.value = e is AppException ? e.message : AppStrings.errorRecording;

      _summaryResponse.value = ApiResponse.error(
        _statusMessage.value,
        e is Exception ? e : null,
      );
    }
  }

  /// Generate a simulated transcription for demo purposes
  String _generateSimulatedTranscription(String title, int timestamp) {
    final currentTime = DateTime.now();
    final formattedTime = "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}";
    final formattedDate =
        "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

    return '''
Good morning everyone. Today is $formattedDate and the time is $formattedTime. We're here for our $title meeting.

First, let's go through the agenda. We need to discuss the current progress on the project, upcoming deadlines, resource allocation, and any blockers that team members are facing.

Sarah: I've completed the initial design work for the front-end interface. We're on track to meet our milestone by next Friday.

John: Thanks, Sarah. The backend team has some concerns about the API integration timeline. We may need an additional week to complete the database migrations.

Michael: I agree with John. We've encountered some unexpected challenges with the legacy systems. I suggest we allocate more resources to the backend team.

Project Manager: That makes sense. Let's reassign two developers from the testing team to help with the backend work. Speaking of timelines, we need to update our client on the adjusted delivery date.

Sarah: I can prepare a presentation showing our progress and explaining the timeline adjustment.

Project Manager: Great, let's schedule that for next Wednesday. Any other concerns?

John: We should also discuss the budget implications of the extended timeline.

Project Manager: Good point. Finance has provided us with some flexibility, but we'll need to be careful about overtime hours.

Michael: On a positive note, the new features we've implemented have received excellent feedback from the beta testers.

Project Manager: That's great to hear! Let's include that in the client presentation.

Sarah: I think we should also mention that despite the slight delay, the quality of the product will be significantly improved.

Project Manager: Absolutely. Let's wrap up this meeting. Our action items are: Sarah will prepare the client presentation, John will lead the database migration with the additional resources, and I'll discuss the budget adjustments with finance.

Thank you everyone for your time and contributions. Our next $title meeting will be next Monday at $formattedTime.
''';
  }

  /// Create a summary with dynamic key points (non-AI)
  SummaryModel _createDynamicSummary(String transcription) {
    debugPrint('DEBUG: Creating dynamic summary from simulated transcription');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final currentTime = DateTime.now();
    final formattedTime = "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}";
    final formattedDate =
        "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

    // Generate dynamic key points based on the summary title and time
    final List<String> keyPointOptions = [
      'The discussion began at $formattedTime with an overview of the agenda.',
      'Key participants shared updates about ongoing ${currentSummary!.title.toLowerCase()} activities.',
      'Important deadlines for ${currentSummary!.title.toLowerCase()} were established for next week.',
      'Team members discussed challenges related to ${currentSummary!.title.toLowerCase()}.',
      'A follow-up ${currentSummary!.title.toLowerCase()} session was scheduled for $formattedDate.',
      'Resources needed for ${currentSummary!.title.toLowerCase()} were identified and assigned.',
      'The team agreed on next steps for progressing with ${currentSummary!.title.toLowerCase()}.',
      'Several action items were assigned to team members regarding ${currentSummary!.title.toLowerCase()}.',
      'Concerns about timeline were addressed during the ${currentSummary!.title.toLowerCase()}.',
      'New opportunities related to ${currentSummary!.title.toLowerCase()} were discussed.',
      'Budget considerations for ${currentSummary!.title.toLowerCase()} were reviewed in detail.',
      'Client feedback on the ${currentSummary!.title.toLowerCase()} was shared with the team.',
    ];

    // Shuffle the list to get random key points each time
    keyPointOptions.shuffle();

    // Take the first 3-5 key points (random number between 3-5)
    final int numberOfPoints = 3 + (timestamp % 3); // Will be 3, 4, or 5 points
    final selectedKeyPoints = keyPointOptions.take(numberOfPoints).toList();

    return currentSummary!.copyWith(
      transcription: transcription,
      keyPoints: selectedKeyPoints,
      status: SummaryStatus.completed,
    );
  }

  /// Reset the controller state
  void reset() {
    _summaryResponse.value = ApiResponse.idle();
    _isRecording.value = false;
    _statusMessage.value = '';
  }
}
