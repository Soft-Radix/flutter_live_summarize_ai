import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Provider for converting speech to text
class SpeechToTextProvider {
  final http.Client _client;

  /// Constructor
  SpeechToTextProvider({http.Client? client}) : _client = client ?? http.Client();

  /// Convert an audio file to text using a mock implementation
  /// In a real app, this would use a speech-to-text API
  Future<String> convertAudioToText(String audioFilePath) async {
    try {
      debugPrint('DEBUG: SpeechToTextProvider - Converting audio file to text: $audioFilePath');

      // Check if the file exists
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        debugPrint('DEBUG ERROR: Audio file does not exist: $audioFilePath');
        return 'Error: Audio file not found';
      }

      // Generate a mock transcription to use for streaming simulation
      final mockTranscription = _generateMockTranscription(audioFilePath);

      // For demonstration purposes, simulate streaming transcription by returning
      // partial results in a real-time manner
      return await _simulateStreamingTranscription(mockTranscription);
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: Error converting audio to text: $e');
      debugPrint('DEBUG ERROR: Stack trace: $stackTrace');
      return 'Error transcribing audio: $e';
    }
  }

  /// Generate a mock transcription
  String _generateMockTranscription(String audioFilePath) {
    final currentTime = DateTime.now();
    final formattedTime = "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}";
    final formattedDate =
        "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

    // Extract a mock meeting title from the file path
    String mockTitle = "Meeting";
    try {
      // Try to extract a timestamp from the filename
      final fileName = audioFilePath.split('/').last;
      final timestamp = int.tryParse(fileName.replaceAll(RegExp(r'[^0-9]'), '')) ??
          DateTime.now().millisecondsSinceEpoch;

      // Create a date from the timestamp if possible
      final fileDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      mockTitle = "Project Review Meeting";
    } catch (e) {
      // If parsing fails, just use generic title
      mockTitle = "Project Meeting";
    }

    // Generate future dates for deadlines
    final nextWeek = DateTime.now().add(const Duration(days: 7));
    final nextMonth = DateTime.now().add(const Duration(days: 30));
    final formattedNextWeek =
        "${nextWeek.year}-${nextWeek.month.toString().padLeft(2, '0')}-${nextWeek.day.toString().padLeft(2, '0')}";
    final formattedNextMonth =
        "${nextMonth.year}-${nextMonth.month.toString().padLeft(2, '0')}-${nextMonth.day.toString().padLeft(2, '0')}";

    return '''
[Meeting Start: $formattedDate at $formattedTime]
[Title: $mockTitle]

Project Manager (Jennifer): Good morning everyone. Thank you for joining our meeting. Today we have several important items to discuss including the project roadmap, recent technical challenges, budget allocation, and upcoming milestones. Let's start with a quick status update from each department.

Development Lead (Alex): Thanks Jennifer. The development team has completed 85% of the planned features for the v2.0 release. We've integrated the new authentication system as scheduled, but we're facing some challenges with the database migration. We'll need an additional three days to complete that work, which pushes our delivery to $formattedNextWeek instead of this Friday.

Jennifer: I see. Are there any dependencies that will be affected by this delay?

Alex: The QA team will have less time for testing, so we might need to adjust the test coverage focus or possibly allocate additional QA resources.

QA Manager (Michael): My team can handle the compressed timeline if we focus primarily on the critical user paths. However, we should consider extending the beta testing period to ensure we catch any edge cases. I propose we run an extended beta until $formattedNextMonth.

Product Owner (Sarah): That sounds reasonable. I've already communicated with our key stakeholders about the potential delay, and they understand given the complexity of the database migration. The most important thing is ensuring data integrity and security.

Jennifer: Agreed. Alex, what resources do you need to ensure the migration completes by $formattedNextWeek?

Alex: I'll need two additional backend engineers to help with the migration scripts and testing. David and Lisa should be able to support this if they can be temporarily reassigned from the analytics project.

Resource Manager (Robert): I can reassign David and Lisa starting tomorrow, but only for one week. After that, they need to return to the analytics project which has a hard deadline from the executive team.

Jennifer: Before we wrap up, let's summarize the key decisions and action items:
1. Development timeline extended to $formattedNextWeek due to database migration challenges
2. David and Lisa will be temporarily reassigned to help with the migration
3. Beta testing will be extended until $formattedNextMonth
4. Alex will provide a detailed migration plan by end of day

[Meeting End: $formattedDate at ${currentTime.hour + 1}:${currentTime.minute.toString().padLeft(2, '0')}]
''';
  }

  /// Simulate streaming transcription by returning partial results with delays
  Future<String> _simulateStreamingTranscription(String fullTranscription) async {
    // Parse the mock transcription to extract sections for streaming simulation
    final lines = fullTranscription.split('\n');

    // Initialize variables to track state
    String currentTranscription = '';
    final controller = StreamController<String>();

    // Get the header section (date, time, title)
    final headerLines = lines.take(3).join('\n');
    currentTranscription = '$headerLines\n\n';

    // Simulate initial loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    controller.add(currentTranscription);

    // Extract dialog turns for streaming
    final dialogLines = lines.skip(3).where((line) => line.trim().isNotEmpty).toList();

    // Simulate streaming transcription by adding lines incrementally
    for (int i = 0; i < dialogLines.length; i++) {
      // Add a small random delay between lines to simulate real-time transcription
      await Future.delayed(Duration(milliseconds: 300 + (50 * (i % 5))));

      currentTranscription += '${dialogLines[i]}\n';
      controller.add(currentTranscription);

      // For longer sentences, simulate typing in chunks
      if (dialogLines[i].length > 100) {
        // Simulate a pause before continuing with the next line
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Simulate final processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Close the stream controller
    await controller.close();

    return fullTranscription;
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
