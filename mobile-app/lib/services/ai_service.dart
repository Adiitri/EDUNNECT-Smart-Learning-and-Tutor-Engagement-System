import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // Python Server URL (localhost:8000)
  static const String baseUrl = "http://localhost:8000";

  static Future<String> askQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question, "history": []}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'];
      } else {
        return "Error: Failed to connect to AI server.";
      }
    } catch (e) {
      return "Error: Is the Python server running? ($e)";
    }
  }
}
