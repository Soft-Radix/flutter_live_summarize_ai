import 'package:flutter_live_summarize_ai/data/providers/audio_player_provider.dart';
import 'package:flutter_live_summarize_ai/data/providers/audio_provider.dart';
import 'package:flutter_live_summarize_ai/data/providers/speech_to_text_provider.dart';
import 'package:flutter_live_summarize_ai/data/repositories/summary_repository.dart';
import 'package:flutter_live_summarize_ai/data/services/gemini_service.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/history_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/home_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/recording_controller.dart';
import 'package:flutter_live_summarize_ai/presentation/controllers/summary_controller.dart';
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

    Get.lazyPut<AudioPlayerProvider>(
      () => AudioPlayerProvider(),
      fenix: true,
    );

    Get.lazyPut<SpeechToTextProvider>(
      () => SpeechToTextProvider(),
      fenix: true,
    );

    // Services
    Get.lazyPut<GeminiService>(
      () => GeminiService(),
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
        geminiService: Get.find<GeminiService>(),
        speechToTextProvider: Get.find<SpeechToTextProvider>(),
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

    // SummaryController - lazily initialized when needed
    Get.lazyPut<SummaryController>(
      () => SummaryController(
        repository: Get.find<SummaryRepository>(),
        audioPlayerProvider: Get.find<AudioPlayerProvider>(),
        geminiService: Get.find<GeminiService>(),
      ),
      fenix: true,
    );
  }
}
