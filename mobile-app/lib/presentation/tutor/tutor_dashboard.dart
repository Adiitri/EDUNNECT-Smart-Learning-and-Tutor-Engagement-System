import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/user_session.dart';
import '../common/login_screen.dart';
import '../student/real_time_chat.dart'; // Reuse the existing chat screen
import 'student_chat_list.dart';     // The new inbox screen we discussed

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final user = UserSession.currentUser;
    if (user == null) return;

    final url = Uri.parse(
      "http://localhost:5000/api/tutors/requests/${user['name']}",
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _requests = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await http.patch(
        Uri.parse("http://localhost:5000/api/tutors/booking/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking $newStatus!")),
      );

      _fetchRequests(); 
    } catch (e) {
      print("Error updating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Welcome, ${user?['name'] ?? 'Tutor'}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // 1. ADDED: Global Inbox Button
          IconButton(
            icon: const Icon(Icons.forum_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentChatList()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              UserSession.currentUser = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No booking requests yet."))
              : RefreshIndicator(
                  onRefresh: _fetchRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final req = _requests[index];
                      final bool isConfirmed = req['status'] == 'Confirmed';

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isConfirmed ? Colors.teal : Colors.orangeAccent,
                                child: Text(req['studentName'][0], style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(req['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Status: ${req['status']}"),
                              
                              // 2. ADDED: Chat Button for individual confirmed bookings
                              trailing: isConfirmed 
                                ? IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => RealTimeChatScreen(
                                            tutor: {
                                              'name': req['studentName'], 
                                              'bookingId': req['_id'],   
                                            }
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : null,
                            ),
                            
                            // Accept/Decline buttons only for Pending
                            if (req['status'] == 'Pending')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatusButton("Accept", Colors.green, () => _updateStatus(req['_id'], "Confirmed")),
                                    _buildStatusButton("Decline", Colors.red, () => _updateStatus(req['_id'], "Rejected")),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildStatusButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}