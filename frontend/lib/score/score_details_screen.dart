import 'package:flutter/material.dart';
import '../model/result_model.dart';

class DetailedReportScreen extends StatelessWidget {
  final ResultModel result;

  const DetailedReportScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          "${result.title} - Detailed Report",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: result.questions.length,
        itemBuilder: (context, index) {
          final q = result.questions[index];

          // Determine box color & icon
          Color boxColor;
          Icon? icon;
          if (q.attemptedAnswer == null) {
            boxColor = Colors.grey.shade800;
            icon = const Icon(Icons.remove, color: Colors.white70);
          } else if (q.isCorrect) {
            boxColor = Colors.green.shade700;
            icon = const Icon(Icons.check, color: Colors.white);
          } else {
            boxColor = Colors.red.shade700;
            icon = const Icon(Icons.close, color: Colors.white);
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  "${index + 1}. ${q.question}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Attempted answer
                if (q.attemptedAnswer != null)
                  Row(
                    children: [
                      const Text(
                        "Your Answer: ",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        q.attemptedAnswer!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      icon,
                    ],
                  ),
                // If wrong, show correct answer
                if (q.attemptedAnswer != null && !q.isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Text(
                          "Correct Answer: ",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          q.correctAnswer,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.check, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                // If not attempted
                if (q.attemptedAnswer == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Text(
                          "Not Attempted",
                          style: TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
