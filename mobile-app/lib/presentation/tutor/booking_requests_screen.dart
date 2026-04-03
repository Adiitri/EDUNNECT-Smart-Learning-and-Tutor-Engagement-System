import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/user_session.dart';
import '../student/real_time_chat.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
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

    final url = Uri.parse("http://localhost:5000/api/tutors/requests/${user['name']}");

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _requests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating booking: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRequests,
              child: _requests.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No booking requests yet.')),
                      ],
                    )
                  : ListView.builder(
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
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : null,
                              ),
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
