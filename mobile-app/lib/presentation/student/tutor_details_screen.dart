import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/user_session.dart'; // <--- CRITICAL IMPORT

class TutorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailsScreen({super.key, required this.tutor});

  @override
  State<TutorDetailsScreen> createState() => _TutorDetailsScreenState();
}

class _TutorDetailsScreenState extends State<TutorDetailsScreen> {
  bool _isBooking = false; // To show loading spinner

  Future<void> _bookSession() async {
    setState(() => _isBooking = true);

    // 1. GET THE REAL LOGGED-IN USER
    final user = UserSession.currentUser;

    // Safety Check: Are they logged in?
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

    final String studentName =
        user['name']; // <--- THIS IS THE FIX (e.g. "Arun")

    // Use _id (MongoDB default) or id
    final String tutorId = widget.tutor['_id'] ?? widget.tutor['id'].toString();

    print("📢 Booking: $studentName booking ${widget.tutor['name']}");

    // 2. SEND REQUEST TO BACKEND
    final url = Uri.parse("http://localhost:5000/api/tutors/book");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tutorId": tutorId,
          "tutorName": widget.tutor['name'],
          "studentName": studentName, // <--- SENDING REAL NAME NOW
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking Confirmed! Check 'My Bookings'."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Optional: Go back to list after success
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        throw Exception("Server rejected booking");
      }
    } catch (e) {
      print("Booking Error: $e");
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
      body: Padding(
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
                  style: const TextStyle(fontSize: 40, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name & Subject
            Text(
              widget.tutor['name'],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                const Icon(Icons.location_on, color: Colors.blue, size: 28),
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

            const Spacer(),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isBooking
                    ? null
                    : _bookSession, // Disable if loading
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Book Session",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
