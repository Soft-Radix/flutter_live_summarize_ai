import 'package:flutter_live_summarize_ai/domain/entities/summary.dart';

/// Data model class for Summary entity
class SummaryModel extends Summary {
  /// Constructor for the SummaryModel class
  SummaryModel({
    required String id,
    required String title,
    required List<String> keyPoints,
    String? transcription,
    String? audioFilePath,
    required DateTime createdAt,
    required SummaryStatus status,
    String? errorMessage,
  }) : super(
          id: id,
          title: title,
          keyPoints: keyPoints,
          transcription: transcription,
          audioFilePath: audioFilePath,
          createdAt: createdAt,
          status: status,
          errorMessage: errorMessage,
        );

  /// Create a SummaryModel from a JSON map
  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>).map((e) => e as String).toList(),
      transcription: json['transcription'] as String?,
      audioFilePath: json['audioFilePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: SummaryStatus.values.byName(json['status'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convert this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'keyPoints': keyPoints,
      'transcription': transcription,
      'audioFilePath': audioFilePath,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  /// Create an empty summary model with recording status
  factory SummaryModel.recording({
    required String id,
    required String title,
  }) {
    return SummaryModel(
      id: id,
      title: title,
      keyPoints: [],
      createdAt: DateTime.now(),
      status: SummaryStatus.recording,
    );
  }

  /// Create a copy of this model with some fields modified
  @override
  SummaryModel copyWith({
    String? id,
    String? title,
    List<String>? keyPoints,
    String? transcription,
    String? audioFilePath,
    DateTime? createdAt,
    SummaryStatus? status,
    String? errorMessage,
  }) {
    return SummaryModel(
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
}
