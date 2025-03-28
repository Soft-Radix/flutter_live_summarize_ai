import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:flutter_live_summarize_ai/core/helpers/api_response.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/providers/audio_provider.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository class for managing summary data
class SummaryRepository {
  final AudioProvider _audioProvider;
  static const String _summariesKey = 'stored_summaries';

  /// Constructor for SummaryRepository
  SummaryRepository({
    required AudioProvider audioProvider,
  }) : _audioProvider = audioProvider;

  /// Create a new summary recording session
  /// Returns the created summary model
  Future<ApiResponse<SummaryModel>> createRecordingSession(String title) async {
    try {
      debugPrint('DEBUG: Creating recording session with title: $title');

      // Generate a unique ID for the summary
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('DEBUG: Generated session ID: $id');

      // Start recording audio
      debugPrint('DEBUG: Starting audio recording through AudioProvider');
      final audioPath = await _audioProvider.startRecording();
      debugPrint('DEBUG: Audio recording started at path: $audioPath');

      // Create a summary model with recording status
      final summary = SummaryModel.recording(
        id: id,
        title: title,
      ).copyWith(
        audioFilePath: audioPath,
      );

      debugPrint('DEBUG: Created summary model with status: ${summary.status}');

      return ApiResponse.completed(summary);
    } catch (e) {
      debugPrint('DEBUG ERROR: Error creating recording session: $e');
      return ApiResponse.error(
        e is AppException ? e.message : 'Failed to create recording session',
        e is Exception ? e : null,
      );
    }
  }

  /// Stop the current recording session
  /// Returns the updated summary model
  Future<ApiResponse<SummaryModel>> stopRecordingSession(SummaryModel summary) async {
    try {
      debugPrint('DEBUG: Stopping recording session for summary ID: ${summary.id}');

      // Stop recording audio
      debugPrint('DEBUG: Stopping audio recording through AudioProvider');
      final audioPath = await _audioProvider.stopRecording();
      debugPrint('DEBUG: Audio recording stopped, path: $audioPath');

      // Update the summary model with the audio path and processing status
      final updatedSummary = summary.copyWith(
        audioFilePath: audioPath,
        status: SummaryStatus.processing,
      );

      debugPrint('DEBUG: Updated summary status to: ${updatedSummary.status}');

      return ApiResponse.completed(updatedSummary);
    } catch (e) {
      debugPrint('DEBUG ERROR: Error stopping recording session: $e');
      return ApiResponse.error(
        e is AppException ? e.message : 'Failed to stop recording session',
        e is Exception ? e : null,
      );
    }
  }

  /// Save the summary to local storage
  /// Returns true if saved successfully
  Future<bool> saveSummary(SummaryModel summary) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing summaries
      final storedSummaries = await getSavedSummaries();

      // Add the new summary to the list
      storedSummaries.add(summary);

      // Convert to JSON string
      final summariesJson = jsonEncode(
        storedSummaries.map((s) => s.toJson()).toList(),
      );

      // Save to shared preferences
      await prefs.setString(_summariesKey, summariesJson);

      return true;
    } catch (e) {
      debugPrint('Error saving summary: $e');
      return false;
    }
  }

  /// Get all saved summaries from local storage
  Future<List<SummaryModel>> getSavedSummaries({bool addSamplesIfEmpty = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final summariesJson = prefs.getString(_summariesKey);

      debugPrint('DEBUG: SummaryRepository - Getting saved summaries');

      if (summariesJson == null || summariesJson.isEmpty) {
        debugPrint('DEBUG: SummaryRepository - No saved summaries found');
        // Add sample summaries if flag is set and none exist
        if (addSamplesIfEmpty) {
          debugPrint('DEBUG: SummaryRepository - Adding sample summaries as none exist');
          await addSampleSummaries();
          return getSavedSummaries(addSamplesIfEmpty: false); // Prevent infinite recursion
        }
        return [];
      }

      final List<dynamic> decoded = jsonDecode(summariesJson);
      final summaries =
          decoded.map((json) => SummaryModel.fromJson(json as Map<String, dynamic>)).toList();
      debugPrint('DEBUG: SummaryRepository - Found ${summaries.length} saved summaries');
      return summaries;
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: SummaryRepository - Error getting saved summaries: $e');
      debugPrint('DEBUG ERROR: SummaryRepository - Stack trace: $stackTrace');
      return [];
    }
  }

  /// Add sample summaries for demonstration
  Future<void> addSampleSummaries() async {
    debugPrint('DEBUG: Adding sample summaries to repository');

    // Sample 1: Weekly Team Meeting
    final sample1 = SummaryModel(
      id: 'sample-1',
      title: 'Weekly Team Meeting',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      keyPoints: [
        'Project Alpha is on track for delivery by the end of the month',
        'Marketing team needs additional resources for the upcoming campaign',
        'Customer feedback shows 92% satisfaction with the new features',
        'Next sprint planning session scheduled for Friday at 10 AM',
        'Budget allocation for Q3 needs revision due to unexpected costs'
      ],
      transcription:
          'Full transcription of the weekly team meeting discussing project progress, challenges, and next steps.',
      status: SummaryStatus.completed,
    );

    // Sample 2: Product Strategy Discussion
    final sample2 = SummaryModel(
      id: 'sample-2',
      title: 'Product Strategy Discussion',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      keyPoints: [
        'New competitor analysis shows we lead in 3 out of 5 key features',
        'User research indicates need for simplified onboarding process',
        'Mobile usage has increased by 35% in the last quarter',
        'Price point should remain stable for next release',
        'International expansion planned for Q4, starting with European markets'
      ],
      transcription:
          'Detailed transcription of the product strategy meeting with stakeholders discussing market trends and competition.',
      status: SummaryStatus.completed,
    );

    // Sample 3: Client Presentation Rehearsal
    final sample3 = SummaryModel(
      id: 'sample-3',
      title: 'Client Presentation Rehearsal',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      keyPoints: [
        'Slide deck needs more visual examples and fewer bullet points',
        'Technical demonstration should be shortened to 5 minutes',
        'ROI section needs more concrete numbers and case studies',
        'Each team member should prepare for specific Q&A topics',
        'Presentation flow improved but timing needs to be tightened'
      ],
      transcription:
          'Transcription of the team rehearsing the upcoming client presentation, with feedback and adjustments.',
      status: SummaryStatus.completed,
    );

    // Sample 4: Financial Review Q2
    final sample4 = SummaryModel(
      id: 'sample-4',
      title: 'Financial Review Q2',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      keyPoints: [
        'Q2 revenue exceeded expectations by 12%, primarily driven by subscription growth',
        'Operating costs increased by 8% due to new hires and office expansion',
        'Customer acquisition cost decreased by 15% thanks to optimized marketing',
        'Cash flow remains positive with 3.5 months of runway at current burn rate',
        'Technology investment for next quarter approved at \$250,000'
      ],
      transcription:
          'Detailed financial review for Q2 with the finance team and department heads discussing performance metrics.',
      status: SummaryStatus.completed,
    );

    // Sample 5: UX Research Findings
    final sample5 = SummaryModel(
      id: 'sample-5',
      title: 'UX Research Findings',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      keyPoints: [
        'Navigation issues identified in the checkout process causing 25% drop-off',
        'Users prefer the new dashboard layout but find the color scheme confusing',
        'Search functionality rated as most important feature by 78% of participants',
        'Personalization options are underutilized due to poor discoverability',
        'Most requested feature is dark mode support across all platforms'
      ],
      transcription:
          'UX research team presenting findings from recent user testing sessions and interviews for the mobile app redesign.',
      status: SummaryStatus.completed,
    );

    // Combine all samples
    final List<SummaryModel> sampleSummaries = [sample1, sample2, sample3, sample4, sample5];

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final summariesJson = jsonEncode(
      sampleSummaries.map((s) => s.toJson()).toList(),
    );

    await prefs.setString(_summariesKey, summariesJson);
    debugPrint('DEBUG: Added ${sampleSummaries.length} sample summaries');
  }

  /// Delete a saved summary
  /// Returns true if deleted successfully
  Future<bool> deleteSummary(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing summaries
      final storedSummaries = await getSavedSummaries();

      // Find the summary to delete
      final summaryToDelete = storedSummaries.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Summary not found'),
      );

      // Delete the audio file if it exists
      if (summaryToDelete.audioFilePath != null) {
        await _audioProvider.deleteRecording(summaryToDelete.audioFilePath!);
      }

      // Remove the summary from the list
      storedSummaries.removeWhere((s) => s.id == id);

      // Convert to JSON string
      final summariesJson = jsonEncode(
        storedSummaries.map((s) => s.toJson()).toList(),
      );

      // Save to shared preferences
      await prefs.setString(_summariesKey, summariesJson);

      return true;
    } catch (e) {
      debugPrint('Error deleting summary: $e');
      return false;
    }
  }

  /// Get a single summary by ID
  Future<SummaryModel?> getSummaryById(String id) async {
    try {
      debugPrint('DEBUG: SummaryRepository - Getting summary by ID: $id');
      final summaries = await getSavedSummaries();

      final summary = summaries.firstWhere(
        (s) => s.id == id,
        orElse: () {
          debugPrint('DEBUG ERROR: SummaryRepository - Summary not found with ID: $id');
          throw Exception('Summary not found');
        },
      );

      debugPrint('DEBUG: SummaryRepository - Found summary with title: ${summary.title}');
      return summary;
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: SummaryRepository - Error getting summary by ID: $e');
      debugPrint('DEBUG ERROR: SummaryRepository - Stack trace: $stackTrace');
      return null;
    }
  }
}
