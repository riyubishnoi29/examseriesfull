import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../model/result_model.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late Future<List<ResultModel>> futureResults;

  @override
  void initState() {
    super.initState();
    futureResults = ApiService.getUserResults();
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
    if (percent >= 80) {
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 28);
    } else if (percent >= 50) {
      return const Icon(
        Icons.military_tech,
        color: Colors.orangeAccent,
        size: 28,
      );
    } else if (percent > 0) {
      return const Icon(
        Icons.sentiment_dissatisfied,
        color: Color(0xFFFF3B30),
        size: 28,
      );
    } else {
      return const Icon(Icons.lock, color: Colors.grey, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your Achievements",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<ResultModel>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading results: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No test results found.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }

          final results = snapshot.data!;
          return ListView.builder(
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

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular Progress Indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              borderColor,
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
                    // Test Details
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
                            "Score: ${r.score}/${r.totalMarks} • Time: ${r.timeTakenMinutes} min",
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
                    // Performance Icon
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
              );
            },
          );
        },
      ),
    );
  }
}
