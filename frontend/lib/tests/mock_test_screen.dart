import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'mock_questions_screen.dart';

class MockTestsScreen extends StatefulWidget {
  final int examId;
  final String examName;

  MockTestsScreen({required this.examId, required this.examName});

  @override
  _MockTestsScreenState createState() => _MockTestsScreenState();
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
      setState(() {
        mockTests = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching mocks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.examName} - Mock Tests")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : mockTests.isEmpty
              ? Center(
                child: Text(
                  "No mock tests available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: mockTests.length,
                itemBuilder: (context, index) {
                  final mock = mockTests[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Text(
                        mock['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "Duration: ${mock['duration_minutes']} min",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuestionsScreen(
                                  mockId: mock['id'],
                                  mockName: mock['title'],
                                  timeLimit: mock['duration_minutes'],
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
