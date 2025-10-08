import 'dart:convert';
import 'package:examtrack/model/result_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "https://rankyard.in";

  static const storage = FlutterSecureStorage();

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
      headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
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

  // --- SIGNUP ---
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'), // ✅ Fixed
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 && data["success"] == true) {
      await storage.write(key: "token", value: data["token"]);
    }
    return data;
  }

  // --- LOGIN ---
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'), // ✅ Fixed
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      await storage.write(key: "token", value: data["token"]);
    }
    return data;
  }

  // --- PROFILE ---
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await storage.read(key: "token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/profile'), // ✅ Fixed
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["user"];
    }
    return null;
  }

  // --- Logout ---
  static Future<void> logout() async {
    await storage.delete(key: "token");
  }

  //save result
  static Future<bool> saveResult(
    int mockId,
    double score,
    double totalMarks,
    int timeTakenMinutes,
    String title,
    List<Map<String, dynamic>> answers,
  ) async {
    final token = await storage.read(key: "token");
    if (token == null) return false;

    // Decode token to get user id
    final payload = jsonDecode(
      ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
    );
    final userId = payload['id'];

    final Map<String, dynamic> resultData = {
      "user_id": userId,
      "mock_id": mockId,
      "score": score,
      "total_marks": totalMarks,
      "time_taken_minutes": timeTakenMinutes,
      "title": title,
      "answers": answers,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resultData),
    );

    return response.statusCode == 200;
  }

  // Get user results
  static Future<List<ResultModel>> getUserResults() async {
    final token = await storage.read(key: "token");
    if (token == null) return [];

    // Decode token to get user id
    final payload = jsonDecode(
      ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
    );
    final userId = payload['id'];

    final response = await http.get(Uri.parse("$baseUrl/results/$userId"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ResultModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load results");
    }
  }
}
