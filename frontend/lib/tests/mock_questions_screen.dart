import 'dart:async';
import 'package:examtrack/tests/question_result_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class QuestionsScreen extends StatefulWidget {
  final int mockId;
  final String mockName;
  final int timeLimit;

  QuestionsScreen({
    required this.mockId,
    required this.mockName,
    required this.timeLimit,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool isLoading = true;
  List questions = [];
  int currentIndex = 0;
  Map<int, String> selectedAnswers = {};
  late int remainingSeconds;
  Timer? timer;

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
      print('Error fetching questions: $e');
      setState(() => isLoading = false);
    }
  }

  void selectAnswer(String answer) {
    setState(() => selectedAnswers[currentIndex] = answer);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (currentIndex < questions.length - 1) {
        setState(() => currentIndex++);
      } else {
        showResult();
      }
    });
  }

  void showResult() async {
    timer?.cancel();
    int score = 0;
    int totalMarks = 0;

    for (int i = 0; i < questions.length; i++) {
      int marks = int.tryParse(questions[i]['marks']?.toString() ?? "1") ?? 1;
      totalMarks += marks;

      final correctAnswer = questions[i]['correct_answer']?.toString() ?? "";
      final selectedAnswer = selectedAnswers[i] ?? "";

      if (selectedAnswer == correctAnswer) {
        score += marks;
      }
    }

    int timeTakenSeconds = widget.timeLimit * 60 - remainingSeconds;
    int timeTakenMinutes = (timeTakenSeconds / 60).ceil();

    await ApiService.saveResult(
      widget.mockId,
      score,
      totalMarks,
      timeTakenMinutes,
      widget.mockName,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultScreen(
              score: score,
              total: totalMarks,
              mockId: widget.mockId,
              title: widget.mockName,
              timeTakenMinutes: timeTakenMinutes,
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
        title: Text(
          widget.mockName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
                : buildQuestionLayout(),
      ),
    );
  }

  Widget buildQuestionLayout() {
    final q = questions[currentIndex];
    final options = List<String>.from(q['options'] ?? []);

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentIndex + 1} of ${questions.length}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Marks: ${q['marks'] ?? 1}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q['question_text'] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                            fontSize: 16,
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
        // ✅ FIXED: Added SafeArea wrapper for bottom buttons
        // ✅ Proper SafeArea with padding for system navigation
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text("Previous"),
                    onPressed:
                        currentIndex > 0
                            ? () => setState(() => currentIndex--)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      currentIndex == questions.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                    label: Text(
                      currentIndex == questions.length - 1 ? "Submit" : "Next",
                    ),
                    onPressed: () {
                      if (currentIndex < questions.length - 1) {
                        setState(() => currentIndex++);
                      } else {
                        showResult();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
