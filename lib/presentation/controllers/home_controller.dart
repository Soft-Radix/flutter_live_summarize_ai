import 'package:flutter_live_summarize_ai/core/routes/app_pages.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:get/get.dart';

/// Controller for the home view
class HomeController extends GetxController {
  final SummaryRepository _summaryRepository;
  final RxList<SummaryModel> _recentSummaries = <SummaryModel>[].obs;
  final RxBool _isLoading = false.obs;

  /// Constructor for HomeController
  HomeController({
    required SummaryRepository summaryRepository,
  }) : _summaryRepository = summaryRepository;

  /// Get the recent summaries
  List<SummaryModel> get recentSummaries => _recentSummaries;

  /// Check if data is loading
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadRecentSummaries();
  }

  /// Navigate to the recording page
  void goToRecording() {
    Get.toNamed(Routes.RECORDING);
  }

  /// Navigate to the history page
  void goToHistory() {
    Get.toNamed(Routes.HISTORY);
  }

  /// Navigate to the settings page
  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  /// Load recent summaries from the repository
  Future<void> loadRecentSummaries() async {
    _isLoading.value = true;

    try {
      final summaries = await _summaryRepository.getSavedSummaries();

      // Sort by date (newest first) and take the 5 most recent
      summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recent = summaries.take(5).toList();

      _recentSummaries.value = recent;
    } catch (e) {
      // Handle error
      _recentSummaries.value = [];
    } finally {
      _isLoading.value = false;
    }
  }

  /// Navigate to the summary details page
  void viewSummaryDetails(String summaryId) {
    Get.toNamed('${Routes.SUMMARY}/$summaryId');
  }
}
