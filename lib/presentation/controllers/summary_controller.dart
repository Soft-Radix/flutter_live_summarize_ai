import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/providers/audio_player_provider.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/data/services/gemini_service.dart';
import 'package:get/get.dart';

/// Controller for managing summary details
class SummaryController extends GetxController {
  final SummaryRepository _repository;
  final AudioPlayerProvider _audioPlayerProvider;
  final GeminiService _geminiService;

  // Observable variables
  final Rx<SummaryModel?> _summary = Rx<SummaryModel?>(null);
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isAudioAvailable = false.obs;
  final RxBool _isPlayingAudio = false.obs;
  final RxDouble _audioProgress = 0.0.obs;
  final RxString _audioPosition = "00:00".obs;
  final RxString _audioDuration = "00:00".obs;
  final RxBool _isEditingTitle = false.obs;
  final RxBool _isRegenerating = false.obs;

  /// Constructor
  SummaryController({
    required SummaryRepository repository,
    required AudioPlayerProvider audioPlayerProvider,
    required GeminiService geminiService,
  })  : _repository = repository,
        _audioPlayerProvider = audioPlayerProvider,
        _geminiService = geminiService;

  /// Getter for summary
  SummaryModel? get summary => _summary.value;

  /// Getter for loading state
  bool get isLoading => _isLoading.value;

  /// Getter for regenerating state
  bool get isRegenerating => _isRegenerating.value;

  /// Getter for error message
  String get errorMessage => _errorMessage.value;

  /// Check if there is an error
  bool get hasError => _errorMessage.value.isNotEmpty;

  /// Check if audio is available for playback
  bool get isAudioAvailable => _isAudioAvailable.value;

  /// Check if audio is currently playing
  bool get isPlayingAudio => _isPlayingAudio.value;

  /// Current audio playback progress (0.0 to 1.0)
  double get audioProgress => _audioProgress.value;

  /// Current audio position as formatted string
  String get audioPosition => _audioPosition.value;

  /// Audio total duration as formatted string
  String get audioDuration => _audioDuration.value;

  /// Whether the title is being edited
  bool get isEditingTitle => _isEditingTitle.value;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DEBUG: SummaryController - onInit called');

    // Initialize audio player listeners
    _setupAudioListeners();

    // Load summary data
    loadSummary();
  }

  /// Set up listeners for audio player updates
  void _setupAudioListeners() {
    // Listen for playback state changes
    _audioPlayerProvider.isPlaying.addListener(() {
      _isPlayingAudio.value = _audioPlayerProvider.isPlaying.value;
    });

    // Listen for progress changes
    _audioPlayerProvider.progress.addListener(() {
      _audioProgress.value = _audioPlayerProvider.progress.value;
    });

    // Listen for position changes
    _audioPlayerProvider.position.addListener(() {
      _audioPosition.value =
          _audioPlayerProvider.formatDuration(_audioPlayerProvider.position.value);
    });

    // Listen for duration changes
    _audioPlayerProvider.duration.addListener(() {
      _audioDuration.value =
          _audioPlayerProvider.formatDuration(_audioPlayerProvider.duration.value);
    });
  }

  @override
  void onClose() {
    debugPrint('DEBUG: SummaryController - onClose called');
    // Stop any ongoing audio playback
    _audioPlayerProvider.stop();
    super.onClose();
  }

  /// Load the summary from the repository using the ID from the route
  Future<void> loadSummary() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      debugPrint('DEBUG: SummaryController - Loading summary data');

      // Get the summary ID from the route
      final summaryId = Get.parameters['id'];
      debugPrint('DEBUG: SummaryController - Summary ID from route: $summaryId');

      if (summaryId == null) {
        debugPrint('DEBUG ERROR: SummaryController - Summary ID not provided');
        throw Exception('Summary ID not provided');
      }

      // Load the summary
      debugPrint('DEBUG: SummaryController - Fetching summary with ID: $summaryId');
      final summaryData = await _repository.getSummaryById(summaryId);

      if (summaryData == null) {
        debugPrint('DEBUG ERROR: SummaryController - Summary not found for ID: $summaryId');
        throw Exception('Summary not found');
      }

      debugPrint('DEBUG: SummaryController - Summary loaded successfully: ${summaryData.title}');
      _summary.value = summaryData;

      // Check if audio file is available
      _isAudioAvailable.value =
          summaryData.audioFilePath != null && summaryData.audioFilePath!.isNotEmpty;

      if (_isAudioAvailable.value) {
        debugPrint('DEBUG: SummaryController - Audio file available, preparing for playback');
        try {
          await _audioPlayerProvider.loadAudio(summaryData.audioFilePath!);
        } catch (e) {
          debugPrint('DEBUG ERROR: SummaryController - Error loading audio: $e');
          _isAudioAvailable.value = false;
        }
      }

      _isLoading.value = false;
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: SummaryController - Error loading summary: $e');
      debugPrint('DEBUG ERROR: SummaryController - Stack trace: $stackTrace');
      _errorMessage.value = e.toString();
      _isLoading.value = false;
    }
  }

  /// Delete the current summary
  Future<bool> deleteSummary() async {
    if (_summary.value == null) {
      debugPrint('DEBUG: SummaryController - Cannot delete, summary is null');
      return false;
    }

    try {
      debugPrint('DEBUG: SummaryController - Deleting summary with ID: ${_summary.value!.id}');

      // Stop any audio playback first
      if (_isPlayingAudio.value) {
        await _audioPlayerProvider.stop();
      }

      // Delete the summary via repository
      final success = await _repository.deleteSummary(_summary.value!.id);

      if (success) {
        debugPrint('DEBUG: SummaryController - Summary deleted successfully');
        return true;
      } else {
        debugPrint('DEBUG ERROR: SummaryController - Failed to delete summary');
        Get.snackbar(
          'Error',
          'Failed to delete summary',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: SummaryController - Error deleting summary: $e');
      Get.snackbar(
        'Error',
        'Failed to delete summary',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  /// Start editing the title
  void startEditingTitle() {
    _isEditingTitle.value = true;
  }

  /// Cancel editing the title
  void cancelEditingTitle() {
    _isEditingTitle.value = false;
  }

  /// Update the summary title
  Future<bool> updateTitle(String newTitle) async {
    if (_summary.value == null) {
      debugPrint('DEBUG: SummaryController - Cannot update title, summary is null');
      return false;
    }

    if (newTitle.isEmpty) {
      debugPrint('DEBUG: SummaryController - Cannot update title, new title is empty');
      Get.snackbar(
        'Error',
        'Title cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    try {
      debugPrint(
          'DEBUG: SummaryController - Updating summary title from "${_summary.value!.title}" to "$newTitle"');

      // Create an updated summary model
      final updatedSummary = _summary.value!.copyWith(title: newTitle);

      // Save the updated summary
      final success = await _repository.saveSummary(updatedSummary);

      if (success) {
        debugPrint('DEBUG: SummaryController - Summary title updated successfully');
        _summary.value = updatedSummary;
        _isEditingTitle.value = false;

        Get.snackbar(
          'Success',
          'Title updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        debugPrint('DEBUG ERROR: SummaryController - Failed to update summary title');
        Get.snackbar(
          'Error',
          'Failed to update title',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: SummaryController - Error updating summary title: $e');
      Get.snackbar(
        'Error',
        'Failed to update title',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  /// Toggle audio playback (play/pause)
  Future<void> toggleAudioPlayback() async {
    if (!_isAudioAvailable.value) {
      debugPrint('DEBUG: SummaryController - Cannot play audio, no audio file available');
      return;
    }

    try {
      await _audioPlayerProvider.togglePlayPause();
    } catch (e) {
      debugPrint('DEBUG ERROR: SummaryController - Error toggling audio playback: $e');
      Get.snackbar(
        'Error',
        'Failed to play audio recording',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Seek audio playback to a specific position (0.0 to 1.0)
  Future<void> seekAudio(double position) async {
    if (!_isAudioAvailable.value) return;

    try {
      await _audioPlayerProvider.seekByPercentage(position);
    } catch (e) {
      debugPrint('DEBUG ERROR: SummaryController - Error seeking audio: $e');
    }
  }

  /// Copy the summary to clipboard
  void copySummaryToClipboard() {
    if (_summary.value == null) {
      debugPrint('DEBUG: SummaryController - Cannot copy, summary is null');
      return;
    }

    debugPrint('DEBUG: SummaryController - Copying summary to clipboard');
    final text = _summary.value!.keyPoints.map((point) => '• $point').join('\n');
    Clipboard.setData(ClipboardData(text: text));

    Get.snackbar(
      'Copied!',
      AppStrings.summaryCopied,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Share the summary
  void shareSummary() {
    debugPrint('DEBUG: SummaryController - Share summary requested');
    // In a real app, this would use a share plugin
    // For now, we'll just copy to clipboard
    copySummaryToClipboard();

    Get.snackbar(
      'Share',
      'Sharing functionality will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Regenerate summary key points using Gemini AI
  Future<bool> regenerateSummaryPoints() async {
    if (_summary.value == null) {
      debugPrint('DEBUG: SummaryController - Cannot regenerate, summary is null');
      return false;
    }

    if (_summary.value!.transcription == null || _summary.value!.transcription!.isEmpty) {
      debugPrint('DEBUG: SummaryController - Cannot regenerate, no transcription available');
      Get.snackbar(
        'Error',
        'No transcription available to regenerate summary points',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    try {
      _isRegenerating.value = true;
      debugPrint('DEBUG: SummaryController - Regenerating summary points with Gemini AI');

      // Use Gemini AI to generate new key points from the transcription
      final newKeyPoints = await _geminiService.generateSummaryFromTranscription(
        _summary.value!.transcription!,
        _summary.value!.title,
      );

      if (newKeyPoints.isEmpty) {
        debugPrint('DEBUG ERROR: SummaryController - Generated key points are empty');
        Get.snackbar(
          'Error',
          'Failed to generate new summary points',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        _isRegenerating.value = false;
        return false;
      }

      debugPrint('DEBUG: SummaryController - Generated ${newKeyPoints.length} new key points');

      // Update the summary with new key points
      final updatedSummary = _summary.value!.copyWith(keyPoints: newKeyPoints);

      // Save the updated summary
      final success = await _repository.saveSummary(updatedSummary);

      if (success) {
        debugPrint('DEBUG: SummaryController - Summary points updated successfully');
        _summary.value = updatedSummary;

        Get.snackbar(
          'Success',
          'Summary points regenerated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        _isRegenerating.value = false;
        return true;
      } else {
        debugPrint('DEBUG ERROR: SummaryController - Failed to update summary with new key points');
        Get.snackbar(
          'Error',
          'Failed to save regenerated summary points',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        _isRegenerating.value = false;
        return false;
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: SummaryController - Error regenerating summary points: $e');
      Get.snackbar(
        'Error',
        'Failed to regenerate summary points',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      _isRegenerating.value = false;
      return false;
    }
  }
}
