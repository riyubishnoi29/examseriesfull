import 'dart:async';
import 'package:examtrack/tests/question_result_screen.dart' show ResultScreen;
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class QuestionsScreen extends StatefulWidget {
  final int mockId;
  final String mockName;
  final int timeLimit; // in minutes

  const QuestionsScreen({
    super.key,
    required this.mockId,
    required this.mockName,
    required this.timeLimit,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool isLoading = true;
  List questions = [];
  int currentIndex = 0;
  Map<int, String> selectedAnswers = {};
  late int remainingSeconds;
  Timer? timer;
  bool isSubmitting = false;

  final Color primaryRed = Colors.redAccent;
  final Color darkBackground = Colors.black;
  final Color optionColor = const Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.timeLimit * 60;
    startTimer();
    fetchQuestions();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        showResult();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> fetchQuestions() async {
    try {
      final data = await ApiService.getQuestions(widget.mockId);
      setState(() {
        questions = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => isLoading = false);
    }
  }

  void selectAnswer(String answer) {
    setState(() => selectedAnswers[currentIndex] = answer);
  }

  void showResult() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    timer?.cancel();
    int score = 0;
    int totalMarks = 0;

    double negativeMarking = 0.0;
    if (questions.isNotEmpty && questions[0]["negative_marking"] != null) {
      negativeMarking =
          double.tryParse(questions[0]["negative_marking"].toString()) ?? 0.0;
    }

    for (int i = 0; i < questions.length; i++) {
      int marks = int.tryParse(questions[i]["marks"].toString()) ?? 1;
      totalMarks += marks;

      final correct = questions[i]["correct_answer"].toString();
      final selected = selectedAnswers[i] ?? "";

      if (selected == correct) {
        score += marks;
      } else if (selected.isNotEmpty && negativeMarking > 0) {
        score -= negativeMarking.toInt();
      }
    }

    int timeTaken = widget.timeLimit * 60 - remainingSeconds;
    int timeTakenMin = (timeTaken / 60).ceil();

    await ApiService.saveResult(
      widget.mockId,
      score,
      totalMarks,
      timeTakenMin,
      widget.mockName,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultScreen(
              mockId: widget.mockId,
              title: widget.mockName,
              timeTakenMinutes: timeTakenMin,
              answers:
                  selectedAnswers.entries
                      .map(
                        (entry) => {
                          "questionIndex": entry.key,
                          "selectedAnswer": entry.value,
                        },
                      )
                      .toList(),
            ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: primaryRed,
        title: Text(widget.mockName),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                )
                : questions.isEmpty
                ? const Center(
                  child: Text(
                    "No questions available",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                : buildQuestionLayout(),
      ),
    );
  }

  Widget buildQuestionLayout() {
    final q = questions[currentIndex];
    final options = List<String>.from(q["options"] ?? []);

    return Column(
      children: [
        LinearProgressIndicator(
          value: 1 - (remainingSeconds / (widget.timeLimit * 60)),
          backgroundColor: Colors.grey.shade800,
          valueColor: AlwaysStoppedAnimation(primaryRed),
          minHeight: 6,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentIndex + 1} of ${questions.length}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    q["question_text"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((opt) {
                    final isSelected = selectedAnswers[currentIndex] == opt;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? primaryRed : Colors.grey.shade700,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color:
                            isSelected
                                ? Colors.redAccent.withOpacity(0.2)
                                : optionColor,
                      ),
                      child: RadioListTile<String>(
                        value: opt,
                        groupValue: selectedAnswers[currentIndex],
                        onChanged: (val) {
                          if (val != null) selectAnswer(val);
                        },
                        title: Text(
                          opt,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.redAccent : Colors.white70,
                          ),
                        ),
                        activeColor: primaryRed,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      currentIndex > 0
                          ? () => setState(() => currentIndex--)
                          : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      currentIndex < questions.length - 1
                          ? () => setState(() => currentIndex++)
                          : showResult,
                  icon: Icon(
                    currentIndex == questions.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    currentIndex == questions.length - 1 ? "Submit" : "Next",
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
