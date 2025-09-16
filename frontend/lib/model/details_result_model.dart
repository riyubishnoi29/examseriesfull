class DetailedResultModel {
  final int id;
  final int userId;
  final int mockId;
  final String title;
  final int score;
  final int totalMarks;
  final int timeTakenMinutes;
  final DateTime dateTaken;
  final List<DetailedQuestionModel> questions;

  DetailedResultModel({
    required this.id,
    required this.userId,
    required this.mockId,
    required this.title,
    required this.score,
    required this.totalMarks,
    required this.timeTakenMinutes,
    required this.dateTaken,
    this.questions = const [],
  });

  factory DetailedResultModel.fromJson(Map<String, dynamic> json) {
    return DetailedResultModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      mockId: json['mock_id'] ?? 0,
      title: json['title'] ?? 'Mock Test',
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 100,
      timeTakenMinutes: json['time_taken_minutes'] ?? 0,
      dateTaken: DateTime.tryParse(json['date_taken'] ?? '') ?? DateTime.now(),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => DetailedQuestionModel.fromJson(q))
              .toList() ??
          [],
    );
  }

  int get attemptedQuestions =>
      questions.where((q) => q.attemptedAnswer != null).length;

  int get notAttemptedQuestions =>
      questions.where((q) => q.attemptedAnswer == null).length;
}

// Question model for detailed report
class DetailedQuestionModel {
  final int questionId;
  final String question;
  final String correctAnswer;
  final String? attemptedAnswer;
  final bool isCorrect;

  DetailedQuestionModel({
    required this.questionId,
    required this.question,
    required this.correctAnswer,
    this.attemptedAnswer,
    this.isCorrect = false,
  });

  factory DetailedQuestionModel.fromJson(Map<String, dynamic> json) {
    return DetailedQuestionModel(
      questionId: json['question_id'] ?? 0,
      question: json['question'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      attemptedAnswer: json['attempted_answer'],
      isCorrect: (json['is_correct'] ?? 0) == 1,
    );
  }
}
