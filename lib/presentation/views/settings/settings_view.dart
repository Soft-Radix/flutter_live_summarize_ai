import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_colors.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/theme_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// View for displaying and managing app settings
class SettingsView extends StatelessWidget {
  /// Constructor for SettingsView
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme settings
          _buildSectionHeader(context, 'Appearance'),
          Obx(() => SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: themeController.isDarkMode,
                onChanged: (value) {
                  themeController.changeThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                secondary: Icon(
                  themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              )),
          const Divider(),

          // Audio settings
          _buildSectionHeader(context, 'Recording'),
          ListTile(
            title: const Text('Audio Quality'),
            subtitle: const Text('High quality (better results)'),
            leading: Icon(
              Icons.settings_voice,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // In a real app, this would open audio quality settings
              _showFeatureNotImplementedDialog(context);
            },
          ),
          const Divider(),

          // API settings
          _buildSectionHeader(context, 'API Settings'),
          ListTile(
            title: const Text('API Keys'),
            subtitle: const Text('Configure API keys for speech and summarization'),
            leading: Icon(
              Icons.key,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // In a real app, this would open API key settings
              _showFeatureNotImplementedDialog(context);
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('English'),
            leading: Icon(
              Icons.language,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // In a real app, this would open language settings
              _showFeatureNotImplementedDialog(context);
            },
          ),
          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            title: const Text('About App'),
            leading: Icon(
              Icons.info_outline,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            onTap: () {
              // Show the about dialog
              showAboutDialog(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: 'v1.0.0',
                applicationIcon: Icon(
                  Icons.mic,
                  size: 40.r,
                  color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                ),
                children: [
                  const Text(
                      'An app that records live audio, converts speech to text, and summarizes key points using AI.'),
                ],
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            onTap: () {
              // In a real app, this would open the privacy policy
              _showFeatureNotImplementedDialog(context);
            },
          ),
          ListTile(
            title: const Text('Terms & Conditions'),
            leading: Icon(
              Icons.description_outlined,
              color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            onTap: () {
              // In a real app, this would open the terms and conditions
              _showFeatureNotImplementedDialog(context);
            },
          ),
          const Divider(),

          // Version info
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color:
                      Get.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a section header with a title
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16.r, right: 16.r, top: 16.r, bottom: 8.r),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Get.isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
        ),
      ),
    );
  }

  /// Show a dialog for features that are not implemented yet
  void _showFeatureNotImplementedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Coming Soon'),
        content: const Text('This feature is not yet implemented in this demo version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
