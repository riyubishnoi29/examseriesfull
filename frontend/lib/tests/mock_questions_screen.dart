import 'dart:async';
import 'package:examtrack/tests/question_result_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class QuestionsScreen extends StatefulWidget {
  final int mockId;
  final String mockName;
  final int timeLimit;
  final double negativeMarking;

  QuestionsScreen({
    required this.mockId,
    required this.mockName,
    required this.timeLimit,
    required this.negativeMarking,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool isLoading = true;
  List questions = [];
  int currentIndex = 0;
  Map<int, String> selectedAnswers = {};
  Set<int> markedQuestions = {};
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
    final questionId = questions[currentIndex]['id'];
    setState(() => selectedAnswers[questionId] = answer);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (currentIndex < questions.length - 1) {
        setState(() => currentIndex++);
      } else {
        showResult();
      }
    });
  }

  void toggleMark() {
    setState(() {
      if (markedQuestions.contains(currentIndex)) {
        markedQuestions.remove(currentIndex);
      } else {
        markedQuestions.add(currentIndex);
      }
    });
  }

  void showResult() async {
    timer?.cancel();

    // Helper to safely parse numbers
    double safeParse(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    double score = 0;
    double totalMarks = 0;

    for (var q in questions) {
      double marks = safeParse(q['marks'], fallback: 1);
      double negativeMarks = safeParse(q['negative_marks'], fallback: 0);
      totalMarks += marks;

      final correctAnswer = q['correct_answer']?.toString() ?? "";
      final selectedAnswer = selectedAnswers[q['id']]?.toString() ?? "";

      if (selectedAnswer == correctAnswer) {
        score += marks;
      } else if (selectedAnswer.isNotEmpty) {
        score -= negativeMarks;
      }
    }

    // Prevent NaN or negative scores
    score = score.isNaN || score < 0 ? 0 : score;
    totalMarks = totalMarks.isNaN ? 0 : totalMarks;

    int timeTakenSeconds = widget.timeLimit * 60 - remainingSeconds;
    int timeTakenMinutes = (timeTakenSeconds / 60).ceil();

    // Debug print to verify
    print(
      "Saving result: score=$score, total=$totalMarks, time=$timeTakenMinutes",
    );

    // Save result safely
    try {
      await ApiService.saveResult(
        widget.mockId,
        score,
        totalMarks,
        timeTakenMinutes,
        widget.mockName,
        selectedAnswers.entries
            .map((e) => {'question_id': e.key, 'selected_option': e.value})
            .toList(),
      );
    } catch (e) {
      print("Error saving result: $e");
    }

    // Navigate to ResultScreen
    if (!mounted) return;
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
              negativeMarking: widget.negativeMarking,
              questions: questions,
              selectedAnswers: selectedAnswers,
            ),
      ),
    );
  }

  void openNavigator() {
    int attempted = selectedAnswers.length;
    int notAttempted = questions.length - attempted;
    int marked = markedQuestions.length;
    int markedAttempted =
        markedQuestions
            .where((i) => selectedAnswers.containsKey(questions[i]['id']))
            .length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Question Navigator",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value:
                              attempted /
                              (questions.isEmpty ? 1 : questions.length),
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation(primaryRed),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$attempted / ${questions.length} Attempted",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _legendBox(
                          Colors.grey,
                          "Not Attempted ($notAttempted)",
                        ),
                        _legendBox(Colors.green, "Attempted ($attempted)"),
                        _legendBox(Colors.orange, "Marked ($marked)"),
                        _legendBox(
                          Colors.purple,
                          "Marked+Attempted ($markedAttempted)",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: questions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemBuilder: (_, i) {
                        bool isMarked = markedQuestions.contains(i);
                        bool isAttempted = selectedAnswers.containsKey(
                          questions[i]['id'],
                        );
                        Color color;
                        if (isMarked && isAttempted) {
                          color = Colors.purple;
                        } else if (isMarked) {
                          color = Colors.orange;
                        } else if (isAttempted) {
                          color = Colors.green;
                        } else {
                          color = Colors.grey;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => currentIndex = i);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${i + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showResult();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text("Submit Test"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _legendBox(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
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

    // Text options (if any)
    final List optionsText = q['options'] is List ? q['options'] : [];

    // Image options (if any)
    final List optionsImages =
        q['options_image'] is List ? q['options_image'] : [];

    // Decide which options to show: prefer text if available
    final List optionsToShow =
        optionsText.isNotEmpty ? optionsText : optionsImages;

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
                  // Question number & marks
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
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              markedQuestions.contains(currentIndex)
                                  ? Icons.flag
                                  : Icons.outlined_flag,
                              color: Colors.orange,
                            ),
                            onPressed: toggleMark,
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question text
                  if (q['question_text'] != null &&
                      q['question_text'].toString().isNotEmpty)
                    Text(
                      q['question_text'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Question image
                  if (q['question_image'] != null &&
                      q['question_image'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Image.network(
                        q['question_image'],
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (c, e, s) => const Text(
                              "Image load error",
                              style: TextStyle(color: Colors.red),
                            ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Options (text or images)
                  ...optionsToShow.map((opt) {
                    final questionId = q['id'];
                    final isSelected = selectedAnswers[questionId] == opt;
                    final bool isImageOption = opt.toString().startsWith(
                      "http",
                    );

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
                        value: opt.toString(),
                        groupValue: selectedAnswers[questionId],
                        onChanged: (val) {
                          if (val != null) selectAnswer(val);
                        },
                        title:
                            isImageOption
                                ? Image.network(
                                  opt,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (c, e, s) => const Text(
                                        "Error loading option image",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                )
                                : Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isSelected
                                            ? Colors.redAccent
                                            : Colors.white70,
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

        // Bottom buttons (same as your original code)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: const Text("Question Palette"),
                      onPressed: openNavigator,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text("Previous"),
                      onPressed:
                          currentIndex > 0
                              ? () => setState(() => currentIndex--)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        currentIndex == questions.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                      label: Text(
                        currentIndex == questions.length - 1
                            ? "Submit"
                            : "Next",
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
