import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "https://examseriesfull-2.onrender.com";
  static const baseUrl2 = "https://examseriesfull-1.onrender.com";
  //"https://examseriesfull-1.onrender.com";
  //'http://localhost:3000'; // ya apke backend ka IP:Port

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

  // Save result
  static Future<bool> saveResult(Map<String, dynamic> resultData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resultData),
    );
    return response.statusCode == 200;
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
}
