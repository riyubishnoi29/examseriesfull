class ResultModel {
  final int id;
  final int userId;
  final int mockId;
  final int score;
  final int timeTakenMinutes;
  final DateTime dateTaken;
  final String title; // updated: was mockName
  final int totalMarks;

  ResultModel({
    required this.id,
    required this.userId,
    required this.mockId,
    required this.score,
    required this.timeTakenMinutes,
    required this.dateTaken,
    this.title = "Mock Test", // default value
    this.totalMarks = 100, // default value
  });
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] ?? 0,
      mockId: json['mock_id'] ?? 0,
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 0, // ✅ Fallback to 0 if null
      timeTakenMinutes: json['time_taken_minutes'] ?? 0,
      title: json['title'] ?? 'Unknown',
      dateTaken: DateTime.tryParse(json['date_taken'] ?? '') ?? DateTime.now(),
      userId: json['user_id'] ?? 0,
    );
  }
}
