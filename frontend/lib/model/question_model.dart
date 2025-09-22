class QuestionModel {
  final String question;
  final String? attemptedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionModel({
    required this.question,
    this.attemptedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      attemptedAnswer: json['attempted_answer'],
      correctAnswer: json['correct_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}
