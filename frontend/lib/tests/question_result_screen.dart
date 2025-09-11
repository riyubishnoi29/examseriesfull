import 'package:flutter/material.dart';
import '../score/score_screen.dart';
import '../services/api_service.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int mockId; // ✅ added
  final String title; // ✅ added
  final int timeTakenMinutes;

  ResultScreen({
    required this.score,
    required this.total,
    required this.mockId,
    required this.title,
    required this.timeTakenMinutes,
  });

  Future<void> _saveResult(BuildContext context) async {
    try {
      await ApiService.saveResult(
        mockId,
        score,
        total,
        timeTakenMinutes,
        title,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving result: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444), // Deep red
        title: const Text(
          "Test Result",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  "Test Completed!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Your Score",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$score / $total",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Time Taken: $timeTakenMinutes min",
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _saveResult(context);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      "Back to Home",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _saveResult(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ScoreScreen()),
                      );
                    },
                    icon: const Icon(Icons.bar_chart, color: Colors.white),
                    label: const Text(
                      "View All Scores",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
