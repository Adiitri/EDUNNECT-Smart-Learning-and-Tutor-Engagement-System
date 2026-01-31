import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  // Use http://10.0.2.2:5000 for Android Emulator
  // Use http://localhost:5000 for iOS or Web
  static const String baseUrl = "http://localhost:5000/api/recommendations";

  static Future<List<dynamic>> getRecommendations(String userId) async {
    try {
      // We pass the userId to get personalized courses from the AI engine
      final response = await http.get(Uri.parse('$baseUrl/$userId'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load recommendations");
      }
    } catch (e) {
      throw Exception("Error connecting to AI server: $e");
    }
  }
}