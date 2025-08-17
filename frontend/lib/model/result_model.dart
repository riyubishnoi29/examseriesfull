class ResultModel {
  final int id;
  final int userId;
  final int mockId;
  final int score;
  final int timeTakenMinutes;
  final DateTime dateTaken;
  final String mockName; // backend me nahi hai, optional
  final int totalMarks; // backend me nahi hai, optional

  ResultModel({
    required this.id,
    required this.userId,
    required this.mockId,
    required this.score,
    required this.timeTakenMinutes,
    required this.dateTaken,
    this.mockName = "Mock Test", // default value
    this.totalMarks = 100, // default value
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'],
      userId: json['user_id'],
      mockId: json['mock_id'],
      score: json['score'],
      timeTakenMinutes: json['time_taken_minutes'],
      dateTaken: DateTime.parse(json['date_taken']),
      mockName: json['mock_name'] ?? "Mock Test",
      totalMarks: json['total_marks'] ?? 100,
    );
  }
}
