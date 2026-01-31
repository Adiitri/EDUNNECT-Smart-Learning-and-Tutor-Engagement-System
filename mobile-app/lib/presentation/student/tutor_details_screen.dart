import '../../../services/tutor_service.dart';
import 'package:flutter/material.dart';

class TutorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailsScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tutor['name']),
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
                  tutor['name'][0],
                  style: const TextStyle(fontSize: 40, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name & Subject
            Text(
              tutor['name'],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              tutor['subject'],
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),

            const Divider(height: 40),

            // Info Row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(tutor['rating'], style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 24),
                const Icon(Icons.location_on, color: Colors.blue, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Nearby", // We can use tutor['location'] here if it fits
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
                // Inside ElevatedButton...
                onPressed: () async {
                  // 1. Show Loading Indicator (optional, but good UX)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Processing booking...")),
                  );

                  // 2. Call the Server
                  bool success = await TutorService.bookTutor(
                    tutor['id'].toString(), // <--- Just 'tutor', no 'widget.'
                    tutor['name'],
                  );

                  // 3. Show Result
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking Confirmed by Server!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking Failed"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
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
