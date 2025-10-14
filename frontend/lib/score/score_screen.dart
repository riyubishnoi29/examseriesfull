import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

      // latest result per mockId
      final latestResults = fetchedResults.fold<List<ResultModel>>([], (
        prev,
        elem,
      ) {
        if (!prev.any((r) => r.mockId == elem.mockId)) prev.add(elem);
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

  Color getStatusColor(double percent) {
    if (percent >= 0.8) return Colors.lightGreen;
    if (percent >= 0.5) return Colors.orange[300]!;
    if (percent > 0) return Colors.redAccent;
    return Colors.grey;
  }

  IconData getStatusIcon(double percent) {
    if (percent >= 0.8) return Icons.emoji_events;
    if (percent >= 0.5) return Icons.star_half;
    if (percent > 0) return Icons.sentiment_dissatisfied;
    return Icons.lock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        title: const Text(
          "Your Achievements ~",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
              : results.isEmpty
              ? const Center(
                child: Text(
                  "No results yet.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  final percent =
                      r.totalMarks > 0
                          ? (r.score / r.totalMarks).clamp(0.0, 1.0)
                          : 0.0;
                  final percentText = ((percent * 100).clamp(
                    0,
                    100,
                  )).toStringAsFixed(0);
                  final color = getStatusColor(percent);
                  final icon = getStatusIcon(percent);
                  final formattedDate = DateFormat(
                    'EEE, MMM d',
                  ).format(r.dateTaken.toLocal());

                  return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    r.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  "$percentText%",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Score + Time info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Score: ${r.score}/${r.totalMarks}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  "Time: ${r.timeTakenMinutes} min",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Progress bar
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    backgroundColor: Colors.grey[700],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                    minHeight: 18,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$percentText%",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms);
                },
              ),
    );
  }
}
