import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/history_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/widgets/summary_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// View for displaying the history of saved summaries
class HistoryView extends GetView<HistoryController> {
  /// Constructor for HistoryView
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary History'),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadSummaries,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List of summaries
              Expanded(
                child: Obx(() {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.summaries.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    itemCount: controller.summaries.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final summary = controller.summaries[index];
                      return Dismissible(
                        key: Key(summary.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16.r),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _confirmDelete();
                        },
                        onDismissed: (direction) {
                          controller.deleteSummary(summary.id);
                        },
                        child: SummaryCard(
                          summary: summary,
                          onTap: () => controller.viewSummary(summary.id),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the empty state when no summaries exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80.r,
            color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Summaries Yet',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your recorded session summaries will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog for deleting a summary
  Future<bool?> _confirmDelete() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Summary'),
        content: const Text(
            'Are you sure you want to delete this summary? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
