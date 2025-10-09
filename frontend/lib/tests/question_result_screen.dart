import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ResultScreen extends StatefulWidget {
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
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveResultAutomatically();
  }

  Future<void> _saveResultAutomatically() async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      bool success = await ApiService.saveResult(
        widget.mockId,
        widget.score,
        widget.total,
        widget.timeTakenMinutes,
        widget.title,
        widget.selectedAnswers.entries
            .map((e) => {'question_id': e.key, 'selected_option': e.value})
            .toList(),
      );

      if (success) {
        if (!mounted) return;
        setState(() => _isSaved = true);
      }
    } catch (e) {
      debugPrint("❌ Error saving result: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    int wrongCount = 0;
    int skippedCount = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final q = widget.questions[i];
      final correctAnswer = q['correct_answer']?.toString() ?? "";
      final selected = widget.selectedAnswers[q['id']] ?? "";

      if (selected.isEmpty) {
        skippedCount++;
      } else if (selected == correctAnswer) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }

    double percentage = (widget.score / widget.total) * 100;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          "Result - ${widget.title}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          if (_isSaved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score Box
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
                // Circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: widget.score / widget.total,
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
                          "${widget.score.toStringAsFixed(2)} / ${widget.total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                  "Time Taken: ${widget.timeTakenMinutes} min",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  "Negative Marking: ${widget.negativeMarking}",
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

          ...List.generate(widget.questions.length, (i) {
            final q = widget.questions[i];
            final correctAnswer = q['correct_answer']?.toString() ?? "";
            final selected = widget.selectedAnswers[q['id']] ?? "";

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
                    Text(
                      "Q${i + 1}. ${q['question_text']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

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
