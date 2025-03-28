/// Represents the status of a summary
enum SummaryStatus {
  /// Summary is being recorded
  recording,

  /// Audio is being processed
  processing,

  /// Summary is being generated
  generating,

  /// Summary is completed
  completed,

  /// Error occurred during the process
  error,
}

/// Entity class representing a summary of a recorded session
class Summary {
  /// Unique identifier of the summary
  final String id;

  /// Title of the summary
  final String title;

  /// List of key points extracted from the transcription
  final List<String> keyPoints;

  /// Original transcription text
  final String? transcription;

  /// Path to the audio file if saved
  final String? audioFilePath;

  /// Date and time when the recording was created
  final DateTime createdAt;

  /// Status of the summary
  final SummaryStatus status;

  /// Error message if any error occurred
  final String? errorMessage;

  /// Constructor for the Summary class
  Summary({
    required this.id,
    required this.title,
    required this.keyPoints,
    this.transcription,
    this.audioFilePath,
    required this.createdAt,
    required this.status,
    this.errorMessage,
  });

  /// Create a copy of this summary with some modified fields
  Summary copyWith({
    String? id,
    String? title,
    List<String>? keyPoints,
    String? transcription,
    String? audioFilePath,
    DateTime? createdAt,
    SummaryStatus? status,
    String? errorMessage,
  }) {
    return Summary(
      id: id ?? this.id,
      title: title ?? this.title,
      keyPoints: keyPoints ?? this.keyPoints,
      transcription: transcription ?? this.transcription,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if the summary is in a final state (completed or error)
  bool get isFinal => status == SummaryStatus.completed || status == SummaryStatus.error;

  /// Check if the summary has key points
  bool get hasKeyPoints => keyPoints.isNotEmpty;

  /// Get a formatted date string
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  /// Get a formatted time string
  String get formattedTime => '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
}
