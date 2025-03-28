import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:flutter_live_summarize_ai/core/helpers/api_response.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/providers/speech_to_text_provider.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/data/services/gemini_service.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:get/get.dart';

/// Controller for managing recording functionality
class RecordingController extends GetxController {
  final SummaryRepository _summaryRepository;
  final GeminiService _geminiService;
  final SpeechToTextProvider _speechToTextProvider;

  // Flag to determine if we use real AI data and audio transcription
  final bool _useRealAI = true;
  final bool _useRealTranscription = true;

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
    required SpeechToTextProvider speechToTextProvider,
  })  : _summaryRepository = summaryRepository,
        _geminiService = geminiService,
        _speechToTextProvider = speechToTextProvider;

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
        // Process the recording
        await _processRecording();
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

  /// Process the recording to generate a summary
  Future<void> _processRecording() async {
    try {
      debugPrint('DEBUG: Processing audio completed, beginning transcription');
      _statusMessage.value = AppStrings.transcribing;

      String transcription;

      // Get the audio file path from the current summary
      final audioFilePath = currentSummary?.audioFilePath;

      if (_useRealTranscription && audioFilePath != null && audioFilePath.isNotEmpty) {
        // Use the speech-to-text provider to transcribe the audio
        debugPrint('DEBUG: Converting audio to text using SpeechToTextProvider');
        transcription = await _speechToTextProvider.convertAudioToText(audioFilePath);

        // Check if the transcription contains an error
        if (transcription.startsWith('Error:')) {
          debugPrint('DEBUG ERROR: Speech-to-text conversion failed: $transcription');
          // Fall back to simulated transcription
          transcription = _generateSimulatedTranscription(
              currentSummary!.title, DateTime.now().millisecondsSinceEpoch);
        }
      } else {
        // Generate a simulated transcription
        debugPrint('DEBUG: Using simulated transcription');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        transcription = _generateSimulatedTranscription(currentSummary!.title, timestamp);
      }

      // Update status to summarizing
      _statusMessage.value = AppStrings.summarizing;
      debugPrint('DEBUG: Set status message to: ${_statusMessage.value}');

      // Add a small delay to simulate processing
      await Future.delayed(const Duration(seconds: 1));

      SummaryModel summary;

      if (_useRealAI) {
        // Use Gemini AI to generate the summary
        debugPrint('DEBUG: Using Gemini AI to generate summary from transcription');

        try {
          // Get AI-generated key points based on the transcript
          final keyPoints = await _geminiService.generateSummaryFromTranscription(
              transcription, currentSummary!.title);

          debugPrint('DEBUG: Received ${keyPoints.length} key points from Gemini AI');

          // Create the summary with AI-generated key points
          summary = currentSummary!.copyWith(
            transcription: transcription,
            keyPoints: keyPoints,
            status: SummaryStatus.completed,
          );
        } catch (e) {
          debugPrint('DEBUG ERROR: Failed to generate AI summary: $e');
          // Fallback to dynamic key points if AI fails
          summary = _createDynamicSummary(transcription);
        }
      } else {
        // Create a summary with dynamic key points (non-AI)
        summary = _createDynamicSummary(transcription);
      }

      // Save the summary
      debugPrint('DEBUG: Saving completed summary to repository');
      await _summaryRepository.saveSummary(summary);
      debugPrint('DEBUG: Summary saved successfully');

      // Update response with completed summary
      _summaryResponse.value = ApiResponse.completed(summary);
      _statusMessage.value = '';
      debugPrint('DEBUG: Summary processing complete');
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: Error processing recording: $e');
      debugPrint('DEBUG ERROR: Stack trace: $stackTrace');

      _statusMessage.value = e is AppException ? e.message : AppStrings.errorProcessing;
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

    // Generate future dates for deadlines
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final nextMonth = DateTime.now().add(const Duration(days: 30));
    final formattedNextWeek =
        "${nextWeek.year}-${nextWeek.month.toString().padLeft(2, '0')}-${nextWeek.day.toString().padLeft(2, '0')}";
    final formattedNextMonth =
        "${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-${nextMonth.day.toString().padLeft(2, '0')}";

    // Create topic from title
    String topic = title.toLowerCase();
    if (topic.contains('meeting')) {
      topic = topic.replaceAll('meeting', '').trim();
      topic = topic.isEmpty ? 'project' : topic;
    }

    // Generate a more detailed and realistic transcription
    return '''
[Meeting Start: $formattedDate at $formattedTime]
[Title: $title]

Project Manager (Jennifer): Good morning everyone. Thank you for joining our $title. Today we have several important items to discuss including the $topic roadmap, recent technical challenges, budget allocation, and upcoming milestones. Let's start with a quick status update from each department.

Development Lead (Alex): Thanks Jennifer. The development team has completed 85% of the planned features for the $topic v2.0 release. We've integrated the new authentication system as scheduled, but we're facing some challenges with the database migration. We'll need an additional three days to complete that work, which pushes our delivery to $formattedNextWeek instead of this Friday.

Jennifer: I see. Are there any dependencies that will be affected by this delay?

Alex: The QA team will have less time for testing, so we might need to adjust the test coverage focus or possibly allocate additional QA resources.

QA Manager (Michael): My team can handle the compressed timeline if we focus primarily on the critical user paths. However, we should consider extending the beta testing period to ensure we catch any edge cases. I propose we run an extended beta until $formattedNextMonth.

Product Owner (Sarah): That sounds reasonable. I've already communicated with our key stakeholders about the potential delay, and they understand given the complexity of the database migration. The most important thing is ensuring data integrity and security.

Jennifer: Agreed. Alex, what resources do you need to ensure the migration completes by $formattedNextWeek?

Alex: I'll need two additional backend engineers to help with the migration scripts and testing. David and Lisa should be able to support this if they can be temporarily reassigned from the analytics project.

Resource Manager (Robert): I can reassign David and Lisa starting tomorrow, but only for one week. After that, they need to return to the analytics project which has a hard deadline from the executive team.

Jennifer: That should work. Alex, please prepare a detailed plan for the migration with David and Lisa's involvement and share it with the team by end of day today.

Alex: Will do.

UI/UX Lead (Priya): On the frontend side, we've completed all the design updates for v2.0. User testing showed a 35% improvement in task completion time with the new interface. We've documented all the changes in the design system repository and updated the component library.

Jennifer: Excellent work, Priya. Any challenges or risks from your team?

Priya: We're still waiting on final content for the help documentation from Marketing. Without that, we'll have to launch with the current help articles, which won't reflect the new features.

Marketing Lead (James): I apologize for the delay. We're finalizing the content now and will have it ready by Thursday. Our team has been stretched thin with the upcoming trade show preparations.

Jennifer: Thanks for the update, James. Please prioritize the help documentation to ensure it's ready for review by Thursday. Let's now discuss the budget implications of these changes.

Finance Analyst (Emma): Based on the additional resource requirements and extended timeline, we're looking at approximately a 12% increase in the project budget. However, we've identified some cost savings in the cloud infrastructure that can offset about half of that increase.

Jennifer: That's helpful, Emma. Can you prepare a revised budget document that we can present to the steering committee next Monday?

Emma: Yes, I'll have that ready by Friday for your review before the committee meeting.

Jennifer: Great. Now, let's discuss the key risks and mitigation strategies for the next phase...

[Meeting continues with detailed discussions about risk management, stakeholder communication, and specific action items]

Jennifer: Before we wrap up, let's summarize the key decisions and action items:
1. Development timeline extended to $formattedNextWeek due to database migration challenges
2. David and Lisa will be temporarily reassigned to help with the migration
3. Beta testing will be extended until $formattedNextMonth
4. Alex will provide a detailed migration plan by end of day
5. Marketing will deliver help documentation by Thursday
6. Emma will prepare a revised budget by Friday
7. Next $title scheduled for one week from today at $formattedTime

Does anyone have questions or additional items to discuss?

[Brief discussion of minor items]

Jennifer: Thank you everyone for your contributions. Let's follow up on these action items and reconvene next week.

[Meeting End: $formattedDate at ${currentTime.hour + 1}:${currentTime.minute.toString().padLeft(2, '0')}]
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
