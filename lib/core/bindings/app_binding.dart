import 'package:flutter_live_summarize_ai/data/providers/audio_provider.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/history_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/home_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/recording_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/theme_controller.dart';
import 'package:get/get.dart';

/// Main application binding for dependency injection
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<AudioProvider>(
      () => AudioProvider(),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<SummaryRepository>(
      () => SummaryRepository(
        audioProvider: Get.find<AudioProvider>(),
      ),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<ThemeController>(
      () => ThemeController(),
      fenix: true,
    );

    Get.lazyPut<RecordingController>(
      () => RecordingController(
        summaryRepository: Get.find<SummaryRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        summaryRepository: Get.find<SummaryRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HistoryController>(
      () => HistoryController(
        summaryRepository: Get.find<SummaryRepository>(),
      ),
      fenix: true,
    );
  }
}
