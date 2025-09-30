import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double score;
  final double total;
  final int mockId;
  final String title;
  final int timeTakenMinutes;
  final double negativeMarking;
  final List questions;
  final Map<int, String> selectedAnswers;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.mockId,
    required this.title,
    required this.timeTakenMinutes,
    required this.negativeMarking,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    int wrongCount = 0;
    int skippedCount = 0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final correctAnswer = q['correct_answer']?.toString() ?? "";
      final selected = selectedAnswers[i] ?? "";

      if (selected.isEmpty) {
        skippedCount++;
      } else if (selected == correctAnswer) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }

    double percentage = (score / total) * 100;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          "Result - $title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Circular progress style score
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / total,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade700,
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.redAccent,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$score / $total",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statBox("Correct", correctCount, Colors.green),
                    _statBox("Wrong", wrongCount, Colors.red),
                    _statBox("Skipped", skippedCount, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  "Time Taken: $timeTakenMinutes min",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  "Negative Marking: $negativeMarking",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Review Questions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(questions.length, (i) {
            final q = questions[i];
            final correctAnswer = q['correct_answer']?.toString() ?? "";
            final selected = selectedAnswers[i] ?? "";

            bool isCorrect = selected == correctAnswer;
            bool isSkipped = selected.isEmpty;

            return Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      "Q${i + 1}. ${q['question_text']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Options
                    ...List<String>.from(q['options']).map((opt) {
                      bool isSelected = selected == opt;
                      bool isAnswer = opt == correctAnswer;

                      Color bgColor = Colors.grey.shade800;
                      IconData? icon;
                      Color? iconColor;

                      if (isSelected && isCorrect) {
                        bgColor = Colors.green;
                        icon = Icons.check_circle;
                        iconColor = Colors.white;
                      } else if (isSelected && !isCorrect) {
                        bgColor = Colors.red;
                        icon = Icons.cancel;
                        iconColor = Colors.white;
                      } else if (isAnswer) {
                        bgColor = Colors.green.shade700;
                        icon = Icons.check;
                        iconColor = Colors.white;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            if (icon != null)
                              Icon(icon, color: iconColor, size: 20),
                          ],
                        ),
                      );
                    }),

                    if (isSkipped)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          "You skipped this question.",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            "$value",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
