import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/user_session.dart';

class TutorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailsScreen({super.key, required this.tutor});

  @override
  State<TutorDetailsScreen> createState() => _TutorDetailsScreenState();
}

class _TutorDetailsScreenState extends State<TutorDetailsScreen> {
  bool _isBooking = false;

  Future<void> _bookSession() async {
    setState(() => _isBooking = true);

    final user = UserSession.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Log In first!"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isBooking = false);
      return;
    }

    final String studentName = user['name'];
    final String tutorId = widget.tutor['_id'] ?? widget.tutor['id'].toString();

    // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
    final url = Uri.parse("http://10.0.2.2:5000/api/tutors/book");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tutorId": tutorId,
          "tutorName": widget.tutor['name'],
          "studentName": studentName,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Booking Confirmed! Check 'My Bookings'."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Server rejected booking");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking Failed. Is Server Running?"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutor['name']),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // ✅ FIX: Use a Column with Expanded to make content scrollable but keep button fixed
      body: Column(
        children: [
          // 1. SCROLLABLE CONTENT AREA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        widget.tutor['name'][0],
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name & Subject
                  Text(
                    widget.tutor['name'],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.tutor['subject'],
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),

                  const Divider(height: 40),

                  // Info Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        widget.tutor['rating'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 24),
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.tutor['location'] ?? "Online",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    "About",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This tutor is highly experienced and has helped many students achieve excellent results in their exams. Verified by Edunnect.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),

                  // Add extra space at bottom of text so it doesn't touch the button
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 2. FIXED BOOK BUTTON AT BOTTOM
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isBooking ? null : _bookSession,
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Book Session",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
