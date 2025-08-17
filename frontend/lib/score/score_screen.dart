import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/result_model.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  late Future<List<ResultModel>> futureResults;

  @override
  void initState() {
    super.initState();
    futureResults = ApiService.getUserResults();
  }

  Color getBorderColor(int score, int total) {
    double percent = (score / total) * 100;
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    if (percent > 0) return Colors.red;
    return Colors.grey; // not attempted
  }

  Icon getPerformanceIcon(int score, int total) {
    double percent = (score / total) * 100;
    if (percent >= 80)
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 28);
    if (percent >= 50)
      return const Icon(Icons.emoji_events, color: Colors.blueGrey, size: 28);
    if (percent > 0)
      return const Icon(Icons.emoji_events, color: Colors.redAccent, size: 28);
    return const Icon(Icons.lock, color: Colors.grey, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Your Achievements"))),
      body: FutureBuilder<List<ResultModel>>(
        future: futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No results yet."));
          }

          final results = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              final borderColor = getBorderColor(r.score, r.totalMarks);
              final icon = getPerformanceIcon(r.score, r.totalMarks);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: icon,
                  ),
                  title: Text(
                    r.mockName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      r.score > 0
                          ? "Score: ${r.score}/${r.totalMarks} | Time: ${r.timeTakenMinutes} min"
                          : "Test not attempted",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  trailing: Text(
                    "${r.dateTaken.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
