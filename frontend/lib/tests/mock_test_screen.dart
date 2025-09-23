import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:examtrack/services/api_service.dart';
import 'package:examtrack/services/auth_screen.dart';
import 'mock_questions_screen.dart';

class MockTestsScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const MockTestsScreen({
    required this.examId,
    required this.examName,
    Key? key,
  }) : super(key: key);

  @override
  State<MockTestsScreen> createState() => _MockTestsScreenState();
}

class _MockTestsScreenState extends State<MockTestsScreen> {
  bool isLoading = true;
  List mockTests = [];

  @override
  void initState() {
    super.initState();
    fetchMockTests();
  }

  Future<void> fetchMockTests() async {
    try {
      final data = await ApiService.getMockTests(widget.examId);
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        mockTests = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching mocks: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> handleStartTest(BuildContext context, mock) async {
    final token = await ApiService.storage.read(key: "token");
    if (token == null) {
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
      if (loggedIn != true) return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QuestionsScreen(
              mockId: mock['id'],
              mockName: mock['title'],
              timeLimit: mock['duration_minutes'],
              negativeMarking:
                  double.tryParse(
                    mock['negative_marking']?.toString() ?? "0",
                  ) ??
                  0.0,
            ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.greenAccent;
      case 'In Progress':
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'In Progress':
        return Icons.play_arrow;
      default:
        return Icons.pending;
    }
  }

  Widget buildMockCard(BuildContext context, mock, int index) {
    final status = mock['status'] ?? 'Not Started';
    final attempted = mock['attempted'] ?? 0;
    final totalQuestions = mock['total_questions'] ?? 0;

    final progress =
        (totalQuestions > 0)
            ? (attempted / totalQuestions).clamp(0.0, 1.0)
            : 0.0;

    final displayPercent = ((progress * 100).clamp(0, 100)).toStringAsFixed(0);

    return GestureDetector(
          onTap: () => handleStartTest(context, mock),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        mock['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      avatar: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 18,
                      ),
                      backgroundColor: _getStatusColor(status).withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Duration and Attempt Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Duration: ${mock['duration_minutes']} min",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "Attempted: $attempted / $totalQuestions",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar with Percentage
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[700],
                        valueColor: const AlwaysStoppedAnimation(
                          Colors.redAccent,
                        ),
                        minHeight: 18,
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "$displayPercent%",
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
                const SizedBox(height: 16),

                // Start/Resume Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    icon: Icon(_getStatusIcon(status), color: Colors.white),
                    label: Text(
                      status == 'Completed'
                          ? "View Result"
                          : status == 'In Progress'
                          ? "Resume Test"
                          : "Start Test",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () => handleStartTest(context, mock),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: (100 * index).ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 2,
        title: Text(
          "${widget.examName} - Mock Tests",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
              : mockTests.isEmpty
              ? const Center(
                child: Text(
                  "No mock tests available",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              )
              : ListView.builder(
                itemCount: mockTests.length,
                itemBuilder:
                    (context, index) =>
                        buildMockCard(context, mockTests[index], index),
              ),
    );
  }
}
