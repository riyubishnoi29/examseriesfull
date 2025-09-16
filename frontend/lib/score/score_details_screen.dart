import 'package:examtrack/services/api_service.dart';
import 'package:flutter/material.dart';

class ResultDetailsScreen extends StatefulWidget {
  final int resultId;
  const ResultDetailsScreen({super.key, required this.resultId});

  @override
  State<ResultDetailsScreen> createState() => _ResultDetailsScreenState();
}

class _ResultDetailsScreenState extends State<ResultDetailsScreen> {
  late Future<Map<String, dynamic>> futureResultDetails;

  @override
  void initState() {
    super.initState();
    futureResultDetails = ApiService.fetchResultDetails(widget.resultId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result Details")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureResultDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Available"));
          }

          final result = snapshot.data!['result'];
          final questions = snapshot.data!['questions'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Result Summary Card
                Card(
                  child: ListTile(
                    title: Text(
                      result['mock_title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Score: ${result['score']}/${result['total_marks']}\nTime: ${result['time_taken_minutes']} mins",
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Questions Attempted List
                const Text(
                  "Questions Attempted",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...questions.map(
                  (q) => Card(
                    color:
                        q['is_correct'] ? Colors.green[100] : Colors.red[100],
                    child: ListTile(
                      title: Text(q['question_text']),
                      subtitle: Text(
                        "Your Answer: ${q['attempted_answer'] ?? 'Not Attempted'}",
                      ),
                      trailing: Text(
                        q['is_correct'] ? "Correct" : "Wrong",
                        style: TextStyle(
                          color: q['is_correct'] ? Colors.green : Colors.red,
                        ),
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
