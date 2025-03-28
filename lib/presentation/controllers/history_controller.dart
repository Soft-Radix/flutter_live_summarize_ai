import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/routes/app_pages.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:get/get.dart';

/// Controller for the history view
class HistoryController extends GetxController {
  final SummaryRepository _summaryRepository;
  final RxList<SummaryModel> _summaries = <SummaryModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSelectionMode = false.obs;
  final RxSet<String> _selectedIds = <String>{}.obs;

  /// Constructor for HistoryController
  HistoryController({
    required SummaryRepository summaryRepository,
  }) : _summaryRepository = summaryRepository;

  /// Get the list of summaries
  List<SummaryModel> get summaries => _summaries;

  /// Check if data is loading
  bool get isLoading => _isLoading.value;

  /// Check if selection mode is active
  bool get isSelectionMode => _isSelectionMode.value;

  /// Get the set of selected summary IDs
  Set<String> get selectedIds => _selectedIds;

  /// Get the count of selected summaries
  int get selectedCount => _selectedIds.length;

  @override
  void onInit() {
    super.onInit();
    loadSummaries();
  }

  /// Load all summaries from the repository
  Future<void> loadSummaries() async {
    _isLoading.value = true;

    try {
      final summaries = await _summaryRepository.getSavedSummaries();

      // Sort by date (newest first)
      summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _summaries.value = summaries;
    } catch (e) {
      // Handle error
      _summaries.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  /// Toggle selection mode
  void toggleSelectionMode() {
    if (_isSelectionMode.value) {
      // Exit selection mode
      _isSelectionMode.value = false;
      _selectedIds.clear();
    } else {
      // Enter selection mode
      _isSelectionMode.value = true;
    }
  }

  /// Toggle selection of a summary
  void toggleSelection(String id) {
    if (!_isSelectionMode.value) {
      _isSelectionMode.value = true;
    }

    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);

      // If no items are selected, exit selection mode
      if (_selectedIds.isEmpty) {
        _isSelectionMode.value = false;
      }
    } else {
      _selectedIds.add(id);
    }
  }

  /// Check if a summary is selected
  bool isSelected(String id) {
    return _selectedIds.contains(id);
  }

  /// Select all summaries
  void selectAll() {
    if (_summaries.isEmpty) return;

    _isSelectionMode.value = true;
    _selectedIds.addAll(_summaries.map((s) => s.id));
  }

  /// Deselect all summaries
  void deselectAll() {
    _selectedIds.clear();
    _isSelectionMode.value = false;
  }

  /// Delete a summary
  Future<void> deleteSummary(String id) async {
    try {
      final success = await _summaryRepository.deleteSummary(id);
      if (success) {
        _summaries.removeWhere((s) => s.id == id);
        _selectedIds.remove(id);

        // If no items are selected, exit selection mode
        if (_selectedIds.isEmpty) {
          _isSelectionMode.value = false;
        }
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: HistoryController - Error deleting summary: $e');
      Get.snackbar(
        'Error',
        'Failed to delete summary',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Delete selected summaries
  Future<void> deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    try {
      int successCount = 0;
      int failCount = 0;

      for (final id in _selectedIds.toList()) {
        final success = await _summaryRepository.deleteSummary(id);
        if (success) {
          _summaries.removeWhere((s) => s.id == id);
          _selectedIds.remove(id);
          successCount++;
        } else {
          failCount++;
        }
      }

      // Exit selection mode after deletion
      _isSelectionMode.value = false;

      // Show result message
      if (successCount > 0) {
        Get.snackbar(
          'Success',
          'Deleted $successCount ${successCount == 1 ? 'summary' : 'summaries'}${failCount > 0 ? ' ($failCount failed)' : ''}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else if (failCount > 0) {
        Get.snackbar(
          'Error',
          'Failed to delete summaries',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: HistoryController - Error deleting selected summaries: $e');
      Get.snackbar(
        'Error',
        'Failed to delete summaries',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// View a summary
  void viewSummary(String id) {
    if (_isSelectionMode.value) {
      toggleSelection(id);
    } else {
      Get.toNamed('${Routes.SUMMARY}/$id');
    }
  }
}
