import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/user_session.dart';
import '../student/real_time_chat.dart';

class StudentChatList extends StatefulWidget {
  const StudentChatList({super.key});

  @override
  State<StudentChatList> createState() => _StudentChatListState();
}

class _StudentChatListState extends State<StudentChatList> {
  // Use a variable for base URL. 
  // IMPORTANT: Use '10.0.2.2' for Android Emulator or your PC's IP for real devices.
  final String baseUrl = 'http://localhost:5000'; 

  Future<List<dynamic>> fetchConfirmedStudents() async {
    final user = UserSession.currentUser;
    final tutorId = user?['_id'];

    if (tutorId == null) {
      debugPrint("❌ Error: No Tutor ID found in session.");
      return Future.error("User session missing");
    }

    try {
      debugPrint("📡 Fetching students from: $baseUrl/api/chat/students/$tutorId");
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/students/$tutorId'),
      ).timeout(const Duration(seconds: 10)); // Stop waiting after 10 seconds

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint("✅ Data received: ${data.length} students found.");
        return data;
      } else {
        debugPrint("⚠️ Server error: ${response.statusCode} - ${response.body}");
        return Future.error("Server returned ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      return Future.error("Failed to connect to backend");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Messages", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {}))
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchConfirmedStudents(),
        builder: (context, snapshot) {
          // 1. Handling Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handling Errors (This prevents infinite spinning on failure)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  Text("Connection Failed", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // 3. Handling Empty Data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No confirmed students yet.\nAccept a booking to start chatting!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(),
              ),
            );
          }

          // 4. Success State
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(booking['studentName']?[0] ?? '?', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(booking['studentName'] ?? "Unknown Student", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: const Text("Confirmed Student"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RealTimeChatScreen(
                        tutor: {
                          'name': booking['studentName'],
                          'bookingId': booking['_id'],
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}