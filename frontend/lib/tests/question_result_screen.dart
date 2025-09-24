import 'package:flutter/material.dart';
import '../score/score_screen.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final double score;
  final double total;
  final int mockId;
  final String title;
  final int timeTakenMinutes;
  final double negativeMarking;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.mockId,
    required this.title,
    required this.timeTakenMinutes,
    required this.negativeMarking,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _alreadySaved = false;

  late double finalScore; // Final score with negative marking

  @override
  void initState() {
    super.initState();
    _calculateFinalScore();
  }

  void _calculateFinalScore() {
    int wrongAnswers = (widget.total - widget.score).toInt();
    finalScore = widget.score - (wrongAnswers * widget.negativeMarking);

    // अगर negative score zero से नीचे चला जाए तो zero दिखाना
    if (finalScore < 0) finalScore = 0;
  }

  Future<void> _saveResult(BuildContext context, VoidCallback onSuccess) async {
    if (_isSaving || _alreadySaved) return;
    setState(() => _isSaving = true);

    try {
      final isSaved = await ApiService.saveResult(
        widget.mockId,
        finalScore, // final score भेजा जा रहा है
        widget.total,
        widget.timeTakenMinutes,
        widget.title,
      );
      if (isSaved) {
        _alreadySaved = true;
        onSuccess();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving result: $e")));
    } finally {
      setState(() => _isSaving = false);
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
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
                  "$finalScore / ${widget.total}",
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
                        _isSaving || _alreadySaved
                            ? null
                            : () => _saveResult(
                              context,
                              () => Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              ),
                            ),
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(
                      _isSaving ? "Saving..." : "Back to Home",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSaving || _alreadySaved
                            ? null
                            : () => _saveResult(
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
                      _isSaving ? "Saving..." : "View All Scores",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
