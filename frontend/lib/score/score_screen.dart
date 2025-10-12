import 'package:examtrack/tests/mock_questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../model/result_model.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<ResultModel> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => isLoading = true);
    try {
      final fetchedResults = await ApiService.getUserResults();
      // Latest attempt per mockId
      final latestResults = fetchedResults.fold<List<ResultModel>>([], (
        prev,
        elem,
      ) {
        if (!prev.any((r) => r.mockId == elem.mockId)) {
          prev.add(elem);
        }
        return prev;
      });

      if (mounted) {
        setState(() {
          results = latestResults;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching results: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color getBorderColor(int score, int total) {
    double percent = total > 0 ? (score / total) * 100 : 0;
    if (percent >= 80) return Colors.greenAccent;
    if (percent >= 50) return Colors.orangeAccent;
    if (percent > 0) return const Color(0xFFFF3B30);
    return Colors.grey;
  }

  Icon getPerformanceIcon(int score, int total) {
    double percent = total > 0 ? (score / total) * 100 : 0;
    if (percent >= 80)
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 28);
    if (percent >= 50)
      return const Icon(
        Icons.emoji_events,
        color: Colors.orangeAccent,
        size: 28,
      );
    if (percent > 0)
      return const Icon(
        Icons.sentiment_dissatisfied,
        color: Color(0xFFFF3B30),
        size: 28,
      );
    return const Icon(Icons.lock, color: Colors.grey, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
        ),
      );
    }

    if (results.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text(
            "No results yet.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Your Achievements ~",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final r = results[index];
          final percent = r.totalMarks > 0 ? r.score / r.totalMarks : 0.0;
          final borderColor = getBorderColor(r.score, r.totalMarks);
          final icon = getPerformanceIcon(r.score, r.totalMarks);
          final formattedDate = DateFormat(
            'EEE, MMM d',
          ).format(r.dateTaken.toLocal());

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular progress + test info
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 7,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                        Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.score > 0
                                ? "Score: ${r.score}/${r.totalMarks} • Time: ${r.timeTakenMinutes} min"
                                : "Test not attempted",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: icon,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ✅ Single Button (Take/Retry Test or Perfect)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          percent >= 1.0 ? Colors.amber : Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (percent >= 1.0) {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                title: const Text(
                                  "🎉 Perfect Score!",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                content: Text(
                                  "You scored ${r.score}/${r.totalMarks}. Amazing!",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "OK",
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        final updatedResult = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuestionsScreen(
                                  mockId: r.mockId,
                                  mockName: r.title,
                                  timeLimit: r.totalMarks,
                                  negativeMarking: r.negativeMarking,
                                ),
                          ),
                        );

                        if (updatedResult != null &&
                            updatedResult is ResultModel) {
                          // ✅ Update the local list immediately
                          setState(() {
                            final idx = results.indexWhere(
                              (res) => res.mockId == updatedResult.mockId,
                            );
                            if (idx != -1) {
                              results[idx] = updatedResult;
                            } else {
                              results.add(updatedResult);
                            }
                          });
                        }
                      }
                    },
                    child: Text(
                      percent >= 1.0
                          ? "Perfect Score!"
                          : (r.score > 0 ? "Retake Test" : "Take Test"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
