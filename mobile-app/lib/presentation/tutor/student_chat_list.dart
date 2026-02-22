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
  Future<List<dynamic>> fetchConfirmedStudents() async {
    final tutorId = UserSession.currentUser?['_id'];
    // This hits the new route you added: /api/chat/students/:tutorId
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/chat/students/$tutorId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Messages", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchConfirmedStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No confirmed students yet. Accept a booking to start chatting!"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    booking['studentName'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  booking['studentName'],
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Confirmed Student"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RealTimeChatScreen(
                        tutor: {
                          'name': booking['studentName'], // Adapt UI to show Student Name
                          'bookingId': booking['_id'],   // Join the unique Booking Room
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