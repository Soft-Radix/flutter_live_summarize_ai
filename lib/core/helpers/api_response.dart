/// Status of an API response
enum ApiStatus {
  /// Request is loading
  loading,

  /// Request completed successfully
  completed,

  /// Request failed with an error
  error,

  /// Request is waiting to be initiated
  idle,
}

/// Generic class to handle API responses
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? message;
  final Exception? error;

  /// Constructor for creating a response in loading state
  ApiResponse.loading() : this._(status: ApiStatus.loading);

  /// Constructor for creating a response in completed state
  ApiResponse.completed(T data)
      : this._(
          status: ApiStatus.completed,
          data: data,
        );

  /// Constructor for creating a response in error state
  ApiResponse.error(String message, [Exception? error])
      : this._(
          status: ApiStatus.error,
          message: message,
          error: error,
        );

  /// Constructor for creating a response in idle state
  ApiResponse.idle() : this._(status: ApiStatus.idle);

  /// Private constructor
  ApiResponse._({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  /// Whether the request is loading
  bool get isLoading => status == ApiStatus.loading;

  /// Whether the request is successful
  bool get isCompleted => status == ApiStatus.completed;

  /// Whether the request failed
  bool get isError => status == ApiStatus.error;

  /// Whether the request is idle
  bool get isIdle => status == ApiStatus.idle;
}
