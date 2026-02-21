import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'real_time_chat.dart';

class TutorChatList extends StatelessWidget {
  final String studentName;
  const TutorChatList({super.key, required this.studentName});

  Future<List<dynamic>> fetchConfirmedTutors() async {
    // This hits your chatController.getConfirmedTutors endpoint
    final response = await http.get(
      Uri.parse("http://localhost:5000/api/chat/tutors/$studentName")
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
        title: Text("My Tutors", style: GoogleFonts.poppins()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchConfirmedTutors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No confirmed tutors found. Messages unlock after a tutor accepts your booking."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(child: Text(booking['tutorName'][0])),
                title: Text(booking['tutorName'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: const Text("Status: Confirmed"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => RealTimeChatScreen(
                      tutor: {
                        'name': booking['tutorName'],
                        'bookingId': booking['_id'], // Uses the Booking ID as the Room ID
                      }
                    ),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}