import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_session.dart';
import 'find_tutor_screen.dart';
import 'my_bookings_screen.dart';
import 'ai_chat_screen.dart';
import 'recommendation_screen.dart';
import '../common/splash_screen.dart';
import 'tutor_chat_list.dart';

// ✅ Import the dynamic profile screen instead of the old static one
import '../common/complete_profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get User Name safely
    final user = UserSession.currentUser;
    final String name = user != null ? user['name'] : "Student";

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ---------------------------------------------------------
      // 1. BOTTOM NAVIGATION BAR
      // ---------------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A00E0),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          // 1. Visually highlight the tapped icon
          setState(() {
            _selectedIndex = index;
          });

          // 2. Navigate, and WAIT for the user to pop back
          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TutorChatList(studentName: name),
              ),
            );
            // 3. When they return, instantly reset the highlight to Home
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompleteProfileScreen(isNewUser: false),
              ),
            );
            // 3. When they return, instantly reset the highlight to Home
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),

      // ---------------------------------------------------------
      // 2. BODY
      // ---------------------------------------------------------
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CUSTOM GRADIENT HEADER
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $name! 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Let's learn something new!",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  _buildHeaderCircleButton(
                    icon: Icons.logout,
                    onTap: () {
                      UserSession.clearSession();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            // DASHBOARD GRID CARDS
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildGradientCard(
                    context,
                    "Find Tutors",
                    Icons.search_rounded,
                    [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindTutorScreen(),
                      ),
                    ),
                  ),
                  _buildGradientCard(
                    context,
                    "AI Tutor",
                    Icons.auto_awesome,
                    [const Color(0xFFBC4E9C), const Color(0xFFF80759)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiChatScreen()),
                    ),
                  ),
                  _buildGradientCard(
                    context,
                    "My Bookings",
                    Icons.calendar_month_rounded,
                    [const Color(0xFFF2994A), const Color(0xFFF2C94C)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyBookingsScreen(),
                      ),
                    ),
                  ),
                  _buildGradientCard(
                    context,
                    "Courses",
                    Icons.recommend_rounded,
                    [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendationScreen(),
                      ),
                    ),
                  ),

                  // MESSAGES CARD
                  _buildGradientCard(
                    context,
                    "Messages",
                    Icons.chat_bubble_rounded,
                    [const Color(0xFF6441A5), const Color(0xFF2a0845)],
                    () {
                      final String currentStudentName =
                          UserSession.currentUser?['name'] ?? "Student";

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TutorChatList(studentName: currentStudentName),
                        ),
                      );
                    },
                  ),

                  // PROFILE CARD
                  _buildGradientCard(
                    context,
                    "Profile",
                    Icons.person_rounded,
                    [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CompleteProfileScreen(isNewUser: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
      ),
    );
  }

  // ✅ UPDATED: Clean layout without the background icon stack
  Widget _buildGradientCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
