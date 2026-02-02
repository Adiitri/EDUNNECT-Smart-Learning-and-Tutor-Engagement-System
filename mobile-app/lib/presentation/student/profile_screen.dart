import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_session.dart';
import '../common/splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserSession.currentUser;
    final String name = user != null ? user['name'] : "Student";
    final String email = user != null ? user['email'] : "student@example.com";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8E2DE2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // ✅ FIX: This makes the page scrollable so it never overflows
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. AVATAR
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFE100FF),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "S",
                  style: GoogleFonts.poppins(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. NAME & EMAIL
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // 3. MENU OPTIONS
              _buildProfileOption(Icons.settings, "Settings", () {}),
              _buildProfileOption(Icons.help_outline, "Help & Support", () {}),
              _buildProfileOption(
                Icons.privacy_tip_outlined,
                "Privacy Policy",
                () {},
              ),

              const SizedBox(height: 40),

              // 4. LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Clear session and go to Splash Screen
                    UserSession.clearSession();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Log Out",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Extra space at bottom for scrolling safety
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for menu items
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
