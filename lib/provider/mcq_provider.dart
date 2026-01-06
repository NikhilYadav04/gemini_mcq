import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mcq_gemini/models/mcq_model.dart';
import '../services/gemini_service.dart';

class MCQProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  List<MCQ> _mcqs = [];
  bool _isLoading = false;
  String? _error;

  List<MCQ> get mcqs => _mcqs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> generateMCQs(String content) async {
    if (content.trim().isEmpty) {
      _error = 'Please provide some content to generate MCQs';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _mcqs = [];
    notifyListeners();

    try {
      _mcqs = await _geminiService.generateMCQs(content);
      _error = null;

      Logger().d(mcqs);
    } catch (e) {
      _error = e.toString();
      _mcqs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearMCQs() {
    _mcqs = [];
    _error = null;
    notifyListeners();
  }
}
