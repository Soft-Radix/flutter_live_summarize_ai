import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/routes/app_pages.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/recording_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// View for recording audio and generating summaries
class RecordingView extends GetView<RecordingController> {
  /// Constructor for RecordingView
  const RecordingView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog if recording is in progress
        if (controller.isRecording) {
          final shouldPop = await _showExitConfirmationDialog();
          if (shouldPop == true) {
            await controller.stopRecording();
          }
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Record Session'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (controller.isRecording) {
                final shouldPop = await _showExitConfirmationDialog();
                if (shouldPop == true) {
                  await controller.stopRecording();
                  Get.back();
                }
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.r),
          child: Obx(() {
            final response = controller.summaryResponse;

            if (response.isError) {
              return _buildErrorState(response.message ?? AppStrings.errorGeneric);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title input field
                _buildTitleInput(),
                SizedBox(height: 32.h),

                // Recording visualization
                _buildRecordingVisualizer(),
                SizedBox(height: 32.h),

                // Status message
                if (controller.statusMessage.isNotEmpty) _buildStatusMessage(),

                // Flexible spacer
                const Spacer(),

                // Bottom control buttons
                _buildControlButtons(),
                SizedBox(height: 16.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Build the title input field
  Widget _buildTitleInput() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Session Title',
        hintText: 'E.g., Team Meeting, Lecture, Interview...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      readOnly: controller.isRecording,
      onSubmitted: (title) {
        if (title.isNotEmpty && !controller.isRecording) {
          controller.startRecording(title);
        }
      },
    );
  }

  // Build the recording visualization
  Widget _buildRecordingVisualizer() {
    return Obx(() {
      final isRecording = controller.isRecording;
      final status = controller.summaryResponse.data?.status;

      // Determine the content based on the current status
      if (isRecording) {
        return _buildActiveRecording();
      } else if (status == SummaryStatus.processing || status == SummaryStatus.generating) {
        return _buildProcessingState();
      } else if (status == SummaryStatus.completed) {
        return _buildCompletedState();
      } else {
        return _buildIdleState();
      }
    });
  }

  // Build the idle state (before recording)
  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 80.r,
            color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.tapToStart,
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build the active recording state
  Widget _buildActiveRecording() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated recording icon
          _buildRecordingAnimation(),
          SizedBox(height: 16.h),
          Text(
            AppStrings.recording,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.recording,
            ),
          ),
        ],
      ),
    );
  }

  // Animated recording icon
  Widget _buildRecordingAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 100.r * value,
          height: 100.r * value,
          decoration: BoxDecoration(
            color: AppColors.recording.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.mic,
              size: 50.r,
              color: AppColors.recording,
            ),
          ),
        );
      },
      child: Container(),
    );
  }

  // Build the processing state
  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.r,
            height: 100.r,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              strokeWidth: 6.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            controller.statusMessage,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // Build the completed state
  Widget _buildCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80.r,
            color: AppColors.completed,
          ),
          SizedBox(height: 16.h),
          Text(
            'Summary Completed',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.completed,
            ),
          ),
        ],
      ),
    );
  }

  // Build the error state
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.r,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.r),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16.sp,
                color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              controller.reset();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Build the status message
  Widget _buildStatusMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        controller.statusMessage,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Build the control buttons
  Widget _buildControlButtons() {
    return Obx(() {
      final isRecording = controller.isRecording;
      final status = controller.summaryResponse.data?.status;

      if (isRecording) {
        // Recording in progress - show stop button
        return ElevatedButton.icon(
          onPressed: () {
            debugPrint('DEBUG: User tapped stop recording button');
            controller.stopRecording();
          },
          icon: const Icon(Icons.stop),
          label: const Text(AppStrings.stopRecording),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.recording,
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        );
      } else if (status == SummaryStatus.completed) {
        // Recording completed - show view summary button
        return ElevatedButton.icon(
          onPressed: () {
            debugPrint('DEBUG: User tapped view summary button');
            final summaryId = controller.currentSummary?.id;
            if (summaryId != null) {
              Get.toNamed('${Routes.SUMMARY}/$summaryId');
            }
          },
          icon: const Icon(Icons.visibility),
          label: const Text('View Summary'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        );
      } else if (status == SummaryStatus.processing || status == SummaryStatus.generating) {
        // Processing in progress - show disabled button
        return ElevatedButton.icon(
          onPressed: null, // Disabled button
          icon: const Icon(Icons.hourglass_top),
          label: const Text(AppStrings.processingAudio),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        );
      } else {
        // Ready to record - show start button
        return ElevatedButton.icon(
          onPressed: () {
            debugPrint('DEBUG: User tapped start recording button');
            // Get the title from the text field
            final title = 'Meeting ${DateTime.now().toString().substring(0, 16)}';
            if (title.isNotEmpty) {
              controller.startRecording(title);
            }
          },
          icon: const Icon(Icons.mic),
          label: const Text(AppStrings.startRecording),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        );
      }
    });
  }

  // Show a confirmation dialog when trying to exit during recording
  Future<bool?> _showExitConfirmationDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Stop Recording?'),
        content: const Text(
            'Are you sure you want to stop recording? This will discard the current session.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }
}
