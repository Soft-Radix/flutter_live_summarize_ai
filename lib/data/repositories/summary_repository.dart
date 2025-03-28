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
  Future<List<SummaryModel>> getSavedSummaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final summariesJson = prefs.getString(_summariesKey);

      if (summariesJson == null || summariesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(summariesJson);

      return decoded.map((json) => SummaryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error getting saved summaries: $e');
      return [];
    }
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
      final summaries = await getSavedSummaries();

      return summaries.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Summary not found'),
      );
    } catch (e) {
      debugPrint('Error getting summary by ID: $e');
      return null;
    }
  }
}
