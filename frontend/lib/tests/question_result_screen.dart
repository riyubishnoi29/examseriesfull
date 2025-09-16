import 'package:flutter/material.dart';
import '../score/score_screen.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final int mockId;
  final String title;
  final int timeTakenMinutes;
  final List<Map<String, dynamic>> answers; // ✅ Answers list pass karenge

  const ResultScreen({
    super.key,
    required this.mockId,
    required this.title,
    required this.timeTakenMinutes,
    required this.answers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSubmitting = false;
  int? _finalScore;
  int? _totalMarks;

  Future<void> _submitTest(BuildContext context, VoidCallback onSuccess) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.submitTest(
        mockId: widget.mockId,
        answers: widget.answers,
        timeTakenMinutes: widget.timeTakenMinutes,
      );

      setState(() {
        _finalScore = result["final_score"];
        _totalMarks = result["total_marks"];
      });

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting test: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444),
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
                const Text(
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
                  _finalScore != null
                      ? "$_finalScore / $_totalMarks"
                      : "Calculating...",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Time Taken: ${widget.timeTakenMinutes} min",
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () => _submitTest(
                              context,
                              () => Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              ),
                            ),
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(
                      _isSubmitting ? "Submitting..." : "Back to Home",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
                    onPressed:
                        _isSubmitting
                            ? null
                            : () => _submitTest(
                              context,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScoreScreen(),
                                ),
                              ),
                            ),
                    icon: const Icon(Icons.bar_chart, color: Colors.white),
                    label: Text(
                      _isSubmitting ? "Submitting..." : "View All Scores",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
