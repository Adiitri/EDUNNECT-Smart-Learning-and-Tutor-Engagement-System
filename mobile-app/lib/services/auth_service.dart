import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // If you are using Chrome, localhost works fine.
  // If you use a real Android phone later, change this to your PC's IP address.
  static const String baseUrl = "http://localhost:5000/api/auth";

  // 1. Login Function
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login Successful - Save the Token
        await _saveToken(data['token']);
        return {"success": true, "data": data};
      } else {
        // Login Failed (Wrong password, etc.)
        return {"success": false, "message": data['msg'] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  // 2. Register Function
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['token']);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data['msg'] ?? "Signup failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }

  // Helper: Save Token to Phone Storage
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Helper: Get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
