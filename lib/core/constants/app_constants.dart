/// API keys and configuration constants
class ApiConstants {
  static const String geminiApiKey = 'AIzaSyCSCFTPEKszR-Q7GrzfLXO8WytYcd5zGoM';

  // Base URL for API requests
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
}
