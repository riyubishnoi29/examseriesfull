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
    int score,
    int totalMarks,
    int timeTakenMinutes,
    String title,
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

  // --- Submit Test API ---
  // Yeh answers bhejkar backend pe score calculate karega
  static Future<Map<String, dynamic>> submitTest({
    required int mockId,
    required List<Map<String, dynamic>> answers,
    required int timeTakenMinutes,
  }) async {
    final token = await storage.read(key: "token");
    if (token == null) throw Exception("User not logged in");

    // Decode token to get user_id
    final payload = jsonDecode(
      ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
    );
    final userId = payload['id'];

    final response = await http.post(
      Uri.parse('$baseUrl/mock_tests/$mockId/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "user_id": userId,
        "answers": answers,
        "time_taken_minutes": timeTakenMinutes,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(
        response.body,
      ); // final_score, correct, wrong return hoga
    } else {
      throw Exception('Failed to submit test: ${response.body}');
    }
  }
}
