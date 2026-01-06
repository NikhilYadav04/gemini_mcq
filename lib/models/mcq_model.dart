class MCQ {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  MCQ({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}
