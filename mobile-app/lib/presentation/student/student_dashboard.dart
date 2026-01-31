import 'package:flutter/material.dart';
import 'find_tutor_screen.dart';
import 'ai_chat_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Quick Logout: Clears stack and goes back to initial route (Login)
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
      // FIX: SingleChildScrollView allows the column to scroll if content is too tall
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What do you want to learn?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Feature 1: Find Tutors
              _buildDashboardCard(
                context,
                title: "Find Nearby Tutors",
                subtitle: "Search by location & subject",
                icon: Icons.map,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FindTutorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature 2: My Bookings
              _buildDashboardCard(
                context,
                title: "My Bookings",
                subtitle: "Check status & schedules",
                icon: Icons.calendar_today,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyBookingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature 3: My Profile
              _buildDashboardCard(
                context,
                title: "My Profile",
                subtitle: "Edit details & settings",
                icon: Icons.person,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature 4: AI Tutor
              _buildDashboardCard(
                context,
                title: "Ask AI Tutor",
                subtitle: "Instant doubts resolution",
                icon: Icons.smart_toy,
                color: Colors.purpleAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiChatScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Feature 5: Recommended Courses (Placeholder)
              _buildDashboardCard(
                context,
                title: "Recommended Courses",
                subtitle: "Based on your interests",
                icon: Icons.book,
                color: Colors.green,
                onTap: () {
                  // Add navigation here later
                },
              ),

              // Extra space at bottom for scrolling
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create the cards
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    String subtitle = "",
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
