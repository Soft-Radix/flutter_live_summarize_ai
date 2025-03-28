import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Widget to display a summary in a card format
class SummaryCard extends StatelessWidget {
  /// The summary to display
  final Summary summary;

  /// Callback function when the card is tapped
  final VoidCallback onTap;

  /// Constructor for SummaryCard
  const SummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      summary.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${summary.formattedDate} ${summary.formattedTime}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Get.isDarkMode
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              // Status indicator
              if (!summary.isFinal)
                Padding(
                  padding: EdgeInsets.only(top: 8.r),
                  child: _buildStatusChip(),
                ),

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.r),
                child: const Divider(),
              ),

              // Key points
              if (summary.hasKeyPoints)
                ...summary.keyPoints.take(2).map((point) => Padding(
                      padding: EdgeInsets.only(bottom: 4.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right,
                            size: 16.r,
                            color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),

              // Show more indicator if there are more points
              if (summary.keyPoints.length > 2)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '+ ${summary.keyPoints.length - 2} more points',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                    ),
                  ),
                ),

              // Empty state
              if (summary.hasKeyPoints == false && summary.isFinal)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.r),
                    child: Text(
                      'No key points available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Get.isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a chip to show the current status of the summary
  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (summary.status) {
      case SummaryStatus.recording:
        chipColor = AppColors.recording;
        statusText = 'Recording';
        break;
      case SummaryStatus.processing:
        chipColor = AppColors.processing;
        statusText = 'Processing';
        break;
      case SummaryStatus.generating:
        chipColor = AppColors.processing;
        statusText = 'Generating';
        break;
      case SummaryStatus.error:
        chipColor = AppColors.error;
        statusText = 'Error';
        break;
      default:
        chipColor = AppColors.completed;
        statusText = 'Completed';
    }

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        statusText,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: 8.r),
      visualDensity: VisualDensity.compact,
    );
  }
}
