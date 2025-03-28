/// Base exception class for app-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  /// Constructor for AppException
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exception thrown when there is a network error
class NetworkException extends AppException {
  /// Constructor for NetworkException
  const NetworkException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Exception thrown when there is an error with API requests
class ApiException extends AppException {
  /// Constructor for ApiException
  const ApiException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Exception thrown when there is an error recording audio
class RecordingException extends AppException {
  /// Constructor for RecordingException
  const RecordingException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Exception thrown when there is an error with speech-to-text conversion
class SpeechToTextException extends AppException {
  /// Constructor for SpeechToTextException
  const SpeechToTextException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Exception thrown when there is an error with text summarization
class SummarizationException extends AppException {
  /// Constructor for SummarizationException
  const SummarizationException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Exception thrown when there is a permission error
class PermissionException extends AppException {
  /// Constructor for PermissionException
  const PermissionException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}
