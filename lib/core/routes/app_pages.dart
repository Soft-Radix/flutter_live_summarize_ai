import 'package:flutter_live_summarize_ai/presentation/views/history/history_view.dart';
import 'package:flutter_live_summarize_ai/presentation/views/home/home_view.dart';
import 'package:flutter_live_summarize_ai/presentation/views/recording/recording_view.dart';
import 'package:flutter_live_summarize_ai/presentation/views/settings/settings_view.dart';
import 'package:flutter_live_summarize_ai/presentation/views/splash/splash_view.dart';
import 'package:flutter_live_summarize_ai/presentation/views/summary/summary_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

/// Class that manages the app navigation routes
class AppPages {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  AppPages._();

  /// The initial route to be loaded when the app starts
  static const INITIAL = Routes.SPLASH;

  /// List of all the routes available in the app
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.RECORDING,
      page: () => RecordingView(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: '${Routes.SUMMARY}/:id',
      page: () => const SummaryView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
