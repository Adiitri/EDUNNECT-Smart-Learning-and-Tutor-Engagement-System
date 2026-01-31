import 'package:flutter/material.dart';
import '../common/login_screen.dart'; // Import Login Screen so we can go back to it
import '../../../services/user_session.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get user from session (or use placeholders if empty)
    final user =
        UserSession.currentUser ?? {'name': 'Guest', 'email': 'No Email'};

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purpleAccent,
                child: Text(
                  user['name'][0].toUpperCase(), // First letter of Name
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name (REAL DATA)
            Text(
              user['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Email (REAL DATA)
            Text(
              user['email'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            // ... (Keep the rest of your code the same: Settings, Logout, etc.)
            const SizedBox(height: 40),

            // Options List
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  elevation: 0,
                ),
                onPressed: () {
                  // Logout Logic:
                  // 1. Clear any saved data (in a real app)
                  // 2. Navigate back to Login Screen and remove all previous screens
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false, // This removes the "Back" arrow
                  );
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
