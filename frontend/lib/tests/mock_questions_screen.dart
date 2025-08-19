import 'dart:async';

import 'package:examtrack/tests/question_result_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class QuestionsScreen extends StatefulWidget {
  final int mockId;
  final String mockName;
  final int timeLimit; // minutes

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

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.timeLimit * 60;
    startTimer();
    fetchQuestions();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
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

    Future.delayed(Duration(milliseconds: 300), () {
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

    // Safe calculation with null checks
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

    // Save result to backend
    await ApiService.saveResult(widget.mockId, score, timeTakenMinutes);

    // Navigate to ResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(score: score, total: totalMarks),
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
      appBar: AppBar(
        title: Text(widget.mockName),
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                formatTime(remainingSeconds),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : questions.isEmpty
              ? Center(child: Text("No questions available"))
              : buildQuestionCard(),
    );
  }

  Widget buildQuestionCard() {
    final q = questions[currentIndex];
    final options = List<String>.from(q['options'] ?? []);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Q${currentIndex + 1}: ${q['question_text'] ?? ""}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...options.map(
                (opt) => RadioListTile<String>(
                  value: opt,
                  groupValue: selectedAnswers[currentIndex],
                  onChanged: (val) {
                    if (val != null) selectAnswer(val);
                  },
                  title: Text(opt),
                ),
              ),
              Spacer(),
              Text(
                "Marks: ${q['marks'] ?? 1}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:examtrack/tests/question_result_screen.dart';
// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';

// class QuestionsScreen extends StatefulWidget {
//   final int mockId;
//   final String mockName;
//   final int timeLimit; // minutes from mock screen

//   QuestionsScreen({
//     required this.mockId,
//     required this.mockName,
//     required this.timeLimit,
//   });

//   @override
//   _QuestionsScreenState createState() => _QuestionsScreenState();
// }

// class _QuestionsScreenState extends State<QuestionsScreen> {
//   bool isLoading = true;
//   List questions = [];
//   int currentIndex = 0;
//   Map<int, String> selectedAnswers = {};

//   late int remainingSeconds;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     remainingSeconds = widget.timeLimit * 60; // minutes → seconds
//     startTimer();
//     fetchQuestions();
//   }

//   void startTimer() {
//     timer = Timer.periodic(Duration(seconds: 1), (t) {
//       if (remainingSeconds > 0) {
//         setState(() {
//           remainingSeconds--;
//         });
//       } else {
//         t.cancel();
//         showResult(); // Auto-submit when time ends
//       }
//     });
//   }

//   String formatTime(int seconds) {
//     int minutes = seconds ~/ 60;
//     int secs = seconds % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
//   }

//   Future<void> fetchQuestions() async {
//     try {
//       final data = await ApiService.getQuestions(widget.mockId);
//       setState(() {
//         questions = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching questions: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void selectAnswer(String answer) {
//     setState(() {
//       selectedAnswers[currentIndex] = answer;
//     });

//     Future.delayed(Duration(milliseconds: 300), () {
//       if (currentIndex < questions.length - 1) {
//         setState(() {
//           currentIndex++;
//         });
//       } else {
//         showResult();
//       }
//     });
//   }

//   void showResult() {
//     timer?.cancel(); // stop timer
//     int score = 0;
//     for (int i = 0; i < questions.length; i++) {
//       if (selectedAnswers[i] == questions[i]['correct_answer']) {
//         score++;
//       }
//     }
//     //result screen per navigate krna questions complete hone k bad
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ResultScreen(score: score, total: questions.length),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.mockName),
//         actions: [
//           Padding(
//             padding: EdgeInsets.all(12),
//             child: Center(
//               child: Text(
//                 formatTime(remainingSeconds),
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body:
//           isLoading
//               ? Center(child: CircularProgressIndicator())
//               : questions.isEmpty
//               ? Center(child: Text("No questions available"))
//               : buildQuestionCard(),
//     );
//   }

//   Widget buildQuestionCard() {
//     final q = questions[currentIndex];
//     final options = List<String>.from(q['options']);

//     return Padding(
//       padding: EdgeInsets.all(12),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 4,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Q${currentIndex + 1}: ${q['question_text']}",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 12),
//               ...options.map((opt) {
//                 return RadioListTile<String>(
//                   value: opt,
//                   groupValue: selectedAnswers[currentIndex],
//                   onChanged: (value) {
//                     if (value != null) {
//                       selectAnswer(value);
//                     }
//                   },
//                   title: Text(opt),
//                 );
//               }).toList(),
//               Spacer(),
//               Text(
//                 "Marks: ${q['marks']}",
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
