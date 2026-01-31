import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorService {
  // Use localhost for Chrome.
  // If you test on a real Android phone later, we'll change this IP.
  static const String baseUrl = "http://localhost:5000/api/tutors";

  static Future<List<dynamic>> getTutors() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load tutors");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }

  // Add this inside the class, below getTutors()
  static Future<bool> bookTutor(String tutorId, String tutorName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/book'), // Calls the new /book route
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tutorId": tutorId,
          "tutorName": tutorName,
          "studentName":
              "Demo Student", // We can replace this with real user data later
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Booking Error: $e");
      return false;
    }
  }
}
