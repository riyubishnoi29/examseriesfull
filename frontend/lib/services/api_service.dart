import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://localhost:3000'; // ya apke backend ka IP:Port

  // Get all exams
  static Future<List<dynamic>> getExams() async {
    final response = await http.get(Uri.parse('$baseUrl/exams'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exams');
    }
  }

  // Get mock tests by examId
  static Future<List<dynamic>> getMockTests(int examId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/exams/$examId/mock_tests'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load mock tests');
    }
  }

  // Get questions by mockId
  static Future<List<dynamic>> getQuestions(int mockId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mock_tests/$mockId/questions'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load questions');
    }
  }

  // Save result
  static Future<bool> saveResult(Map<String, dynamic> resultData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resultData),
    );
    return response.statusCode == 200;
  }
}
