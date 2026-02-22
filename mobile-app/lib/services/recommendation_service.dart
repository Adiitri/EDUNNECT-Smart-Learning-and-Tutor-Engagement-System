import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  // 🎯 Use 127.0.0.1 for Chrome Web.
  // (Note: Use your IP like 192.168.x.x if testing on a real mobile device)
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<dynamic>> getRecommendations(String userId) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/recommendations/$userId"))
          .timeout(const Duration(seconds: 5)); // Don't wait forever

      if (response.statusCode == 200) {
        // Successfully got data from Python FastAPI
        return jsonDecode(response.body);
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      // This triggers the 'snapshot.hasError' in your RecommendationScreen
      print("Error in RecommendationService: $e");
      throw Exception(
        "Could not connect to AI Engine. Is it running on port 8000?",
      );
    }
  }
}
