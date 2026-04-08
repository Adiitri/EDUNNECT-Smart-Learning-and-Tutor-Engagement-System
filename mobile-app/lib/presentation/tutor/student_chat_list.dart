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
  Map<String, int> unseenCounts = {}; // Track unseen messages per student
  List<dynamic>? studentsList;

  @override
  void initState() {
    super.initState();
    _loadStudentsAndCounts();
  }

  Future<void> _loadStudentsAndCounts() async {
    final user = UserSession.currentUser;
    final tutorId = user?['_id'];

    if (tutorId == null) {
      debugPrint("❌ Error: No Tutor ID found in session.");
      return;
    }

    try {
      debugPrint("📡 Fetching students from: $baseUrl/api/chat/students/$tutorId");
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/students/$tutorId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint("✅ Data received: ${data.length} students found.");
        
        if (mounted) {
          setState(() {
            studentsList = data;
          });
        }
        
        // Load unseen counts in background
        for (var booking in data) {
          _loadUnseenCount(booking['_id']);
        }
      } else {
        debugPrint("⚠️ Server error: ${response.statusCode} - ${response.body}");
        if (mounted) {
          setState(() {
            studentsList = [];
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      if (mounted) {
        setState(() {
          studentsList = [];
        });
      }
    }
  }

  Future<void> _loadUnseenCount(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/chat/unseen/$bookingId")
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          unseenCounts[bookingId] = data['unseenCount'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading unseen count: $e");
    }
  }

  Future<void> _markAsRead(String bookingId) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/api/chat/mark-read/$bookingId"),
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
        title: Text("Student Messages", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadStudentsAndCounts();
              });
            },
          )
        ],
      ),
      body: studentsList == null
          ? const Center(child: CircularProgressIndicator())
          : studentsList!.isEmpty
              ? Center(
                  child: Text(
                    "No confirmed students yet.\nAccept a booking to start chatting!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(),
                  ),
                )
              : ListView.builder(
                  itemCount: studentsList!.length,
                  itemBuilder: (context, index) {
                    final booking = studentsList![index];
                    final bookingId = booking['_id'];
                    final unseenCount = unseenCounts[bookingId] ?? 0;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(booking['studentName']?[0] ?? '?', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(booking['studentName'] ?? "Unknown Student", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Confirmed Student"),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RealTimeChatScreen(
                              tutor: {
                                'name': booking['studentName'],
                                'bookingId': bookingId,
                              },
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    );
                  },
                ),
    );
  }
}