import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/error/app_exception.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class for handling app permissions
class PermissionHelper {
  /// Private constructor to avoid instantiation
  PermissionHelper._();

  /// Request microphone permission required for audio recording
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Check if microphone permission is granted
  static Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Check and request microphone permission with user feedback
  static Future<bool> checkAndRequestMicrophonePermission() async {
    try {
      // Check if we already have permission
      final hasPermission = await hasMicrophonePermission();
      if (hasPermission) return true;

      // Request permission if not already granted
      final permissionGranted = await requestMicrophonePermission();
      if (permissionGranted) return true;

      // If permission denied, show a dialog to inform the user
      _showPermissionDeniedDialog();
      return false;
    } catch (e) {
      throw PermissionException(
        message: 'Failed to request microphone permission',
        details: e,
      );
    }
  }

  /// Show a dialog when permission is denied
  static void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(AppStrings.errorMicPermission),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
