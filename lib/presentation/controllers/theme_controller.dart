import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing the application's theme mode
class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  /// Get the current theme mode
  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  /// Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeKey);

      if (savedThemeMode != null) {
        if (savedThemeMode == 'light') {
          _themeMode.value = ThemeMode.light;
        } else if (savedThemeMode == 'dark') {
          _themeMode.value = ThemeMode.dark;
        } else {
          _themeMode.value = ThemeMode.system;
        }
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode.value = ThemeMode.system;
    }
  }

  /// Change the theme mode and save the preference
  Future<void> changeThemeMode(ThemeMode mode) async {
    try {
      _themeMode.value = mode;

      final prefs = await SharedPreferences.getInstance();
      String themeValue;

      if (mode == ThemeMode.light) {
        themeValue = 'light';
      } else if (mode == ThemeMode.dark) {
        themeValue = 'dark';
      } else {
        themeValue = 'system';
      }

      await prefs.setString(_themeKey, themeValue);
      Get.changeThemeMode(mode);
    } catch (e) {
      // Error handling for theme change failure
      debugPrint('Error changing theme mode: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark);
    } else {
      await changeThemeMode(ThemeMode.light);
    }
  }

  /// Check if dark mode is enabled
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;
}
