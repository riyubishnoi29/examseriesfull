import 'package:examtrack/services/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:examtrack/services/api_service.dart';

import 'mock_questions_screen.dart'; // ✅ yeh tumhara questions screen

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

  Future<void> handleStartTest(BuildContext context, mock) async {
    final token = await ApiService.storage.read(key: "token");

    if (token == null) {
      // 👇 Full screen AuthScreen open
      final loggedIn = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );

      if (loggedIn != true) return; // user ne login cancel kar diya
    }

    // ✅ Ab user login hai → direct test screen
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
                      contentPadding: EdgeInsets.all(16),
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Duration: ${mock['duration_minutes']} min",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: Icon(Icons.play_arrow, color: Colors.white),
                              label: Text("Start Test"),
                              onPressed: () => handleStartTest(context, mock),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
