import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'real_time_chat.dart';

class TutorChatList extends StatefulWidget {
  final String studentName;
  const TutorChatList({super.key, required this.studentName});

  @override
  State<TutorChatList> createState() => _TutorChatListState();
}

class _TutorChatListState extends State<TutorChatList> {
  Map<String, int> unseenCounts = {}; // Track unseen messages per tutor
  List<dynamic>? tutorsList;

  @override
  void initState() {
    super.initState();
    _loadTutorsAndCounts();
  }

  Future<void> _loadTutorsAndCounts() async {
    // First load tutors
    final response = await http.get(
      Uri.parse("http://localhost:5000/api/chat/tutors/${widget.studentName}")
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        tutorsList = data;
      });
      
      // Then load unseen counts in background
      for (var booking in data) {
        _loadUnseenCount(booking['_id']);
      }
    }
  }

  Future<void> _loadUnseenCount(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/chat/unseen/$bookingId")
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            unseenCounts[bookingId] = data['unseenCount'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading unseen count: $e");
    }
  }

  Future<void> _markAsRead(String bookingId) async {
    try {
      await http.post(
        Uri.parse("http://localhost:5000/api/chat/mark-read/$bookingId"),
      );
      setState(() {
        unseenCounts[bookingId] = 0;
      });
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
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
      body: tutorsList == null
          ? const Center(child: CircularProgressIndicator())
          : tutorsList!.isEmpty
              ? const Center(child: Text("No confirmed tutors found. Messages unlock after a tutor accepts your booking."))
              : ListView.builder(
                  itemCount: tutorsList!.length,
                  itemBuilder: (context, index) {
                    final booking = tutorsList![index];
                    final bookingId = booking['_id'];
                    final unseenCount = unseenCounts[bookingId] ?? 0;
                    
                    return ListTile(
                      leading: CircleAvatar(child: Text(booking['tutorName'][0])),
                      title: Text(booking['tutorName'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Status: Confirmed"),
                      trailing: unseenCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unseenCount',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          : null,
                      onTap: () {
                        _markAsRead(bookingId);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => RealTimeChatScreen(
                            tutor: {
                              'name': booking['tutorName'],
                              'bookingId': bookingId,
                            }
                          ),
                        )).then((_) {
                          // Refresh when returning from chat
                          setState(() {});
                        });
                      },
                    );
                  },
                ),
    );
  }
}