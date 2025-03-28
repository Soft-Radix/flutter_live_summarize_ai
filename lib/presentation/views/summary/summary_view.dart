import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/data/models/summary_model.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// View for displaying a generated summary
class SummaryView extends StatefulWidget {
  /// Constructor for SummaryView
  const SummaryView({super.key});

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  final SummaryRepository _repository = Get.find<SummaryRepository>();
  SummaryModel? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  /// Load the summary from the repository using the ID from the route
  Future<void> _loadSummary() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get the summary ID from the route
      final summaryId = Get.parameters['id'];
      if (summaryId == null) {
        throw Exception('Summary ID not provided');
      }

      // Load the summary
      final summary = await _repository.getSummaryById(summaryId);
      if (summary == null) {
        throw Exception('Summary not found');
      }

      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Copy the summary to clipboard
  void _copySummaryToClipboard() {
    if (_summary == null) return;

    final text = _summary!.keyPoints.map((point) => '• $point').join('\n');
    Clipboard.setData(ClipboardData(text: text));

    Get.snackbar(
      'Copied!',
      AppStrings.summaryCopied,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Share the summary
  void _shareSummary() {
    // In a real app, this would use a share plugin
    // For now, we'll just copy to clipboard
    _copySummaryToClipboard();

    Get.snackbar(
      'Share',
      'Sharing functionality will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_summary?.title ?? AppStrings.summary),
        actions: [
          if (_summary != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareSummary,
              tooltip: AppStrings.shareSummary,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Build the body based on the current state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color:
                      Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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

    return _buildSummaryContent();
  }

  /// Build the summary content
  Widget _buildSummaryContent() {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _summary!.title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${_summary!.formattedDate}\n${_summary!.formattedTime}',
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

          // List of key points
          if (_summary!.hasKeyPoints) ..._buildKeyPoints() else _buildEmptySummary(),

          // Transcription (if available)
          if (_summary!.transcription != null && _summary!.transcription!.isNotEmpty)
            _buildTranscription(),

          // Bottom spacing
          SizedBox(height: 72.h),
        ],
      ),
    );
  }

  /// Build the list of key points
  List<Widget> _buildKeyPoints() {
    return _summary!.keyPoints.map((point) {
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
              _summary!.transcription!,
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
