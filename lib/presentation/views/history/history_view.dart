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
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: controller.loadSummaries,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List of summaries
                Expanded(
                  child: _buildSummariesList(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: controller.isSelectionMode
            ? FloatingActionButton(
                backgroundColor: AppColors.error,
                onPressed: () => _showDeleteSelectedConfirmationDialog(context),
                child: const Icon(Icons.delete),
              )
            : null,
      );
    });
  }

  /// Build the app bar with selection options
  AppBar _buildAppBar() {
    return AppBar(
      title: controller.isSelectionMode
          ? Text('${controller.selectedCount} selected')
          : const Text('Summary History'),
      actions: [
        if (controller.isSelectionMode) ...[
          // Select all button
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: controller.selectAll,
            tooltip: 'Select All',
          ),
          // Cancel selection button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.deselectAll,
            tooltip: 'Cancel',
          ),
        ] else
          // Enter selection mode button
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: controller.toggleSelectionMode,
            tooltip: 'Select Multiple',
          ),
      ],
    );
  }

  /// Build the list of summaries
  Widget _buildSummariesList() {
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
          child: InkWell(
            onLongPress: () => controller.toggleSelection(summary.id),
            onTap: () => controller.viewSummary(summary.id),
            child: Stack(
              children: [
                SummaryCard(
                  summary: summary,
                  onTap: () => controller.viewSummary(summary.id),
                ),
                if (controller.isSelectionMode)
                  Positioned(
                    top: 10.r,
                    right: 10.r,
                    child: Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isSelected(summary.id)
                            ? AppColors.primaryLight
                            : Colors.grey.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.r,
                        ),
                      ),
                      child: controller.isSelected(summary.id)
                          ? Icon(
                              Icons.check,
                              size: 16.r,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog for deleting selected summaries
  Future<void> _showDeleteSelectedConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Selected Summaries'),
          content: Text(
            'Are you sure you want to delete ${controller.selectedCount} selected ${controller.selectedCount == 1 ? 'summary' : 'summaries'}? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.deleteSelected();
              },
            ),
          ],
        );
      },
    );
  }
}
