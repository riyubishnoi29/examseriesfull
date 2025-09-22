import 'package:examtrack/model/question_model.dart';

class ResultModel {
  final int id;
  final int userId;
  final int mockId;
  final int score;
  final int timeTakenMinutes;
  final DateTime dateTaken;
  final String title;
  final int totalMarks;
  final List<QuestionModel> questions;
  int get attemptedQuestions =>
      questions.where((q) => q.attemptedAnswer != null).length;

  int get notAttemptedQuestions =>
      questions.where((q) => q.attemptedAnswer == null).length;
  final double negativeMarking;

  ResultModel({
    required this.id,
    required this.userId,
    required this.mockId,
    required this.score,
    required this.timeTakenMinutes,
    required this.dateTaken,
    this.title = "Mock Test",
    this.totalMarks = 100,
    this.questions = const [],
    this.negativeMarking = 0.0,
  });
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] ?? 0,
      mockId: json['mock_id'] ?? 0,
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      timeTakenMinutes: json['time_taken_minutes'] ?? 0,
      title: json['title'] ?? 'Unknown',
      dateTaken: DateTime.tryParse(json['date_taken'] ?? '') ?? DateTime.now(),
      userId: json['user_id'] ?? 0,
      negativeMarking:
          json['negative_marking'] != null
              ? double.tryParse(json['negative_marking'].toString()) ?? 0.0
              : 0.0,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
