import 'package:examtrack/features/widgets/exam_tile.dart';
import 'package:examtrack/tests/mock_test_screen.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isLoading = true;
  List exams = [];

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      final data = await ApiService.getExams();
      setState(() {
        exams = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching exams: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Exams"), backgroundColor: Colors.black),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Heading in two lines
                      Text(
                        "Master Your Exam Journey\nwith Us.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 20), // Gap after heading
                      // Exam tiles
                      ...exams.map((exam) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExamTile(
                            title: exam['name'] ?? '',
                            imageUrl: exam['logo_url'] ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MockTestsScreen(
                                        examId: exam['id'],
                                        examName: exam['name'],
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 20), // Gap after tiles
                      // Student selection box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black26,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "50,240",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Students Selection",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "We are proud to help thousands of students in securing their dream job",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
