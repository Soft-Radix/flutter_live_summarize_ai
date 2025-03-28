import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/home_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/theme_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/widgets/summary_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// The main home view of the application
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the theme controller for dark mode toggle
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Dark mode toggle
          Obx(() => IconButton(
                icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeController.toggleTheme,
              )),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadRecentSummaries,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(),
              SizedBox(height: 24.h),

              // Recent summaries section
              _buildRecentSummaries(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToRecording,
        label: const Text(AppStrings.startRecording),
        icon: const Icon(Icons.mic),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build the header section with welcome message and info
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Live Summarize AI',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Record live audio and get instant summaries',
          style: TextStyle(
            fontSize: 16.sp,
            color: Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  // Build the recent summaries section
  Widget _buildRecentSummaries() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Summaries',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: controller.goToHistory,
                child: const Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // List of recent summaries
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.recentSummaries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 64.r,
                        color: Get.isDarkMode
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No summaries yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Get.isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap the button below to start recording',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Get.isDarkMode
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.recentSummaries.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final summary = controller.recentSummaries[index];
                  return SummaryCard(
                    summary: summary,
                    onTap: () => controller.viewSummaryDetails(summary.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Build the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            controller.goToHistory();
            break;
          case 2:
            controller.goToSettings();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
