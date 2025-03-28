import 'package:flutter_live_summarize_ai/core/routes/app_pages.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:get/get.dart';

/// Controller for the history view
class HistoryController extends GetxController {
  final SummaryRepository _summaryRepository;
  final RxList<SummaryModel> _summaries = <SummaryModel>[].obs;
  final RxBool _isLoading = false.obs;

  /// Constructor for HistoryController
  HistoryController({
    required SummaryRepository summaryRepository,
  }) : _summaryRepository = summaryRepository;

  /// Get the list of summaries
  List<SummaryModel> get summaries => _summaries;

  /// Check if data is loading
  bool get isLoading => _isLoading.value;

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

  /// Delete a summary
  Future<void> deleteSummary(String id) async {
    try {
      final success = await _summaryRepository.deleteSummary(id);
      if (success) {
        _summaries.removeWhere((s) => s.id == id);
      }
    } catch (e) {
      // Handle error
    }
  }

  /// View a summary
  void viewSummary(String id) {
    Get.toNamed('${Routes.SUMMARY}/$id');
  }
}
