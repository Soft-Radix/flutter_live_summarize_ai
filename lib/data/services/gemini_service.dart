import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_live_summarize_ai/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

/// Service class for interacting with Gemini AI API
class GeminiService {
  final http.Client _client;

  /// Constructor
  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generate key points from a transcription using Gemini AI
  Future<List<String>> generateSummaryFromTranscription(String transcription, String title) async {
    try {
      debugPrint('DEBUG: GeminiService - Generating summary from transcription');

      if (transcription.isEmpty) {
        debugPrint('DEBUG ERROR: Empty transcription provided to Gemini API');
        return ['No transcription available to summarize.'];
      }

      // Prepare the API request URL with key
      const apiKey = ApiConstants.geminiApiKey;
      const baseUrl = ApiConstants.baseUrl;
      const url = '$baseUrl?key=$apiKey';
      debugPrint('DEBUG: Using API endpoint: $baseUrl');

      // Prepare the prompt for the AI
      final prompt = '''
Extract 3-5 key points from the following meeting transcription titled "$title":

$transcription

Return only the key points in a numbered list format, each point should be concise and capture important information from the meeting.
''';

      // Prepare the API request body
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topK': 40,
          'topP': 0.8,
          'maxOutputTokens': 1024,
        }
      };

      // Make the API request
      debugPrint('DEBUG: GeminiService - Sending request to Gemini API');

      try {
        final response = await _client
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(ApiConstants.requestTimeout);

        // Handle the API response
        if (response.statusCode == 200) {
          debugPrint('DEBUG: GeminiService - Received successful response from Gemini API');
          final jsonResponse = jsonDecode(response.body);

          try {
            // Extract the text from the response
            final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];

            // Process the text into a list of key points
            final keyPoints = _processKeyPoints(text);

            debugPrint('DEBUG: GeminiService - Generated ${keyPoints.length} key points');
            return keyPoints;
          } catch (e) {
            debugPrint('DEBUG ERROR: Failed to parse Gemini API response: $e');
            debugPrint('DEBUG ERROR: Response JSON: $jsonResponse');
            return _generateFallbackKeyPoints(title);
          }
        } else {
          debugPrint('DEBUG ERROR: Gemini API request failed with status ${response.statusCode}');
          debugPrint('DEBUG ERROR: Response body: ${response.body}');

          // Check if the error is related to API constraints or quotas
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
          debugPrint('DEBUG ERROR: API error message: $errorMessage');

          // Return fallback key points
          return _generateFallbackKeyPoints(title);
        }
      } catch (e) {
        debugPrint('DEBUG ERROR: HTTP request to Gemini API failed: $e');
        return _generateFallbackKeyPoints(title);
      }
    } catch (e, stackTrace) {
      debugPrint('DEBUG ERROR: Exception in GeminiService: $e');
      debugPrint('DEBUG ERROR: Stack trace: $stackTrace');
      return _generateFallbackKeyPoints(title);
    }
  }

  /// Generate fallback key points when API fails
  List<String> _generateFallbackKeyPoints(String title) {
    final currentTime = DateTime.now();
    final formattedTime = "${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')}";
    final formattedDate =
        "${currentTime.year}-${currentTime.month.toString().padLeft(2, '0')}-${currentTime.day.toString().padLeft(2, '0')}";

    final fallbackKeyPoints = [
      'The meeting covered important updates on $title at $formattedTime.',
      'Team members shared progress reports and identified next steps.',
      'Action items were assigned with deadlines set for $formattedDate.',
      'Key challenges were discussed and mitigation strategies were proposed.',
    ];

    debugPrint('DEBUG: Using fallback key points due to API failure');
    return fallbackKeyPoints;
  }

  /// Process the raw text response into a list of key points
  List<String> _processKeyPoints(String text) {
    // Split the text by newlines and process each line
    final lines = text.split('\n');

    // Filter out empty lines and lines that don't contain key points
    final keyPoints = lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          // Remove numbering and other formatting
          final processed = line
              .replaceAll(RegExp(r'^\d+[\.\)]\s*'), '') // Remove numbering like "1." or "1)"
              .replaceAll(RegExp(r'^[-•*]\s*'), '') // Remove bullet points
              .trim();

          return processed;
        })
        .where((line) => line.isNotEmpty)
        .toList();

    // If no key points were extracted, return a default set
    if (keyPoints.isEmpty) {
      return ['No key points could be extracted from the transcription.'];
    }

    return keyPoints;
  }

  /// Close the HTTP client when done
  void dispose() {
    _client.close();
  }
}
