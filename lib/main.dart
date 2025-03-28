import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/bindings/app_binding.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_strings.dart';
import 'package:flutter_live_summarize_ai/core/routes/app_pages.dart';
import 'package:flutter_live_summarize_ai/core/theme/app_theme.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/theme_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Based on standard iPhone X size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          initialBinding: AppBinding(),
        );
      },
    );
  }
}
