import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/summary_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// View for displaying a generated summary
class SummaryView extends GetView<SummaryController> {
  /// Constructor for SummaryView
  const SummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.summary?.title ?? AppStrings.summary)),
        actions: [
          Obx(() {
            if (controller.summary != null) {
              return Row(
                children: [
                  // Edit title button
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditTitleDialog(context),
                    tooltip: 'Edit Title',
                  ),
                  // Delete summary button
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    tooltip: 'Delete Summary',
                  ),
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: controller.shareSummary,
                    tooltip: AppStrings.shareSummary,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Show dialog to edit the summary title
  Future<void> _showEditTitleDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController(
      text: controller.summary?.title ?? '',
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Title'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Enter new title',
              labelText: 'Title',
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty) {
                  final success = await controller.updateTitle(titleController.text.trim());
                  if (success) {
                    Navigator.of(dialogContext).pop();
                  }
                } else {
                  Get.snackbar(
                    'Error',
                    'Title cannot be empty',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to confirm summary deletion
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Summary'),
          content: const Text(
            'Are you sure you want to delete this summary? This action cannot be undone.',
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
                final success = await controller.deleteSummary();
                Navigator.of(dialogContext).pop();
                if (success) {
                  Get.back(); // Return to previous screen
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Build the body based on the current state
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError) {
        return _buildErrorState();
      }

      return _buildSummaryContent();
    });
  }

  /// Build the error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.r,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Summary',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              controller.errorMessage,
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
      ),
    );
  }

  /// Build the summary content
  Widget _buildSummaryContent() {
    final summary = controller.summary!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary header
          Card(
            margin: EdgeInsets.only(bottom: 16.r),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section with edit option
                  InkWell(
                    onTap: () => _showEditTitleDialog(Get.context!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  summary.title,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                size: 16.r,
                                color: Get.isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${summary.formattedDate}\n${summary.formattedTime}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Get.isDarkMode
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add audio player if audio is available
                  Obx(() {
                    if (controller.isAudioAvailable) {
                      return Column(
                        children: [
                          SizedBox(height: 16.h),
                          const Divider(),
                          SizedBox(height: 8.h),
                          _buildAudioPlayer(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // Key summary points
          Text(
            AppStrings.keySummaryPoints,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),

          // Regenerate button
          Padding(
            padding: EdgeInsets.only(bottom: 12.r),
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed:
                    controller.isRegenerating ? null : () => controller.regenerateSummaryPoints(),
                icon: controller.isRegenerating
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.r,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Get.theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(Icons.auto_awesome, size: 16.r),
                label: Text(controller.isRegenerating ? 'Regenerating...' : 'Generate AI Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  textStyle: TextStyle(fontSize: 14.sp),
                  padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                ),
              );
            }),
          ),

          // List of key points
          if (summary.hasKeyPoints) ..._buildKeyPoints() else _buildEmptySummary(),

          // Transcription (if available)
          if (summary.transcription != null && summary.transcription!.isNotEmpty)
            _buildTranscription(),

          // Bottom spacing
          SizedBox(height: 72.h),
        ],
      ),
    );
  }

  /// Build the audio player widget
  Widget _buildAudioPlayer() {
    return Column(
      children: [
        // Play/Pause button and time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Play/Pause button
            Obx(() {
              return IconButton(
                onPressed: controller.toggleAudioPlayback,
                icon: Icon(
                  controller.isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 42.r,
                  color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              );
            }),

            // Time display
            Obx(() {
              return Text(
                '${controller.audioPosition} / ${controller.audioDuration}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color:
                      Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              );
            }),
          ],
        ),

        // Seek bar
        Obx(() {
          return SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.r,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
              activeTrackColor: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
              inactiveTrackColor: (Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight)
                  .withOpacity(0.3),
              thumbColor: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            child: Slider(
              value: controller.audioProgress,
              onChanged: controller.seekAudio,
              min: 0.0,
              max: 1.0,
            ),
          );
        }),

        // Label
        Padding(
          padding: EdgeInsets.only(left: 8.r, bottom: 8.r),
          child: Row(
            children: [
              Icon(
                Icons.mic,
                size: 16.r,
                color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              SizedBox(width: 4.w),
              Text(
                'Original Recording',
                style: TextStyle(
                  fontSize: 12.sp,
                  color:
                      Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the list of key points
  List<Widget> _buildKeyPoints() {
    return controller.summary!.keyPoints.map((point) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.arrow_right,
              size: 24.r,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                point,
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Build the empty summary state
  Widget _buildEmptySummary() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Column(
          children: [
            Icon(
              Icons.notes,
              size: 64.r,
              color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.emptySummary,
              style: TextStyle(
                fontSize: 16.sp,
                color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the transcription section
  Widget _buildTranscription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        const Divider(),
        SizedBox(height: 16.h),
        Text(
          'Transcription',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              controller.summary!.transcription!,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Get.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
