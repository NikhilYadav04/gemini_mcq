import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mcq_gemini/models/mcq_model.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  String get _apiKey {
    const defineKey = String.fromEnvironment('GEMINI_API_KEY');
    if (defineKey.isNotEmpty) return defineKey;

    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  Future<List<MCQ>> generateMCQs(String content) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'API key not found. Please set GEMINI_API_KEY using --dart-define or .env file');
    }

    final prompt = '''
Generate exactly 5 multiple choice questions from the following content.
Return ONLY a valid JSON array, with no additional text, markdown, or explanation.

Format:
[
  {
    "question": "Question text here?",
    "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
    "correctAnswer": "A) Option 1",
    "explanation": "Brief explanation why this is correct"
  }
]

Content:
$content

Remember: Return ONLY the JSON array, nothing else.
''';

    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        return _parseMCQResponse(response.body);
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(
            'Invalid request: ${error['error']['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('API error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('Rate limit') ||
          e.toString().contains('timeout') ||
          e.toString().contains('internet')) {
        rethrow;
      }
      throw Exception('Failed to generate MCQs: ${e.toString()}');
    }
  }

  List<MCQ> _parseMCQResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      final candidates = decoded['candidates'] as List?;

      if (candidates == null || candidates.isEmpty) {
        throw Exception('No content generated. Please try again.');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      final text = parts[0]['text'] as String;

      // Extract JSON from response
      String jsonText = text.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      // Find JSON array boundaries
      final startIndex = jsonText.indexOf('[');
      final endIndex = jsonText.lastIndexOf(']');

      if (startIndex == -1 || endIndex == -1) {
        throw Exception('No valid JSON array found in response');
      }

      jsonText = jsonText.substring(startIndex, endIndex + 1);

      final List<dynamic> mcqList = jsonDecode(jsonText);

      if (mcqList.isEmpty) {
        throw Exception(
            'No MCQs generated. Please provide more detailed content.');
      }

      return mcqList.map((json) => MCQ.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Parse error: $e');
      throw Exception(
          'Failed to parse MCQs. The AI response was not in the expected format.');
    }
  }
}
