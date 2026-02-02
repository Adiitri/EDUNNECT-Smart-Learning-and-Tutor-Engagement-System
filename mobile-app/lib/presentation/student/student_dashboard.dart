import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_session.dart';
import 'find_tutor_screen.dart';
import 'my_bookings_screen.dart';
import 'ai_chat_screen.dart';
import 'recommendation_screen.dart';
import 'profile_screen.dart';
import '../common/splash_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get User Name safely
    final user = UserSession.currentUser;
    final String name = user != null ? user['name'] : "Student";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ---------------------------
          // 1. CUSTOM GRADIENT HEADER
          // ---------------------------
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
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
                // LOGOUT BUTTON
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      UserSession.clearSession();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------
          // 2. DASHBOARD GRID CARDS
          // ---------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                // ✅ 1.4 is tall enough to hold content safely
                childAspectRatio: 1.4,
                children: [
                  // CARD 1: FIND TUTORS
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

                  // CARD 2: AI TUTOR
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

                  // CARD 3: MY BOOKINGS
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

                  // CARD 4: RECOMMENDATIONS
                  _buildGradientCard(
                    context,
                    "Courses",
                    Icons.recommend_rounded,
                    [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecommendationScreen(),
                        ),
                      );
                    },
                  ),

                  // CARD 5: PROFILE
                  _buildGradientCard(
                    context,
                    "Profile",
                    Icons.person_rounded,
                    [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED GRADIENT CARD (SMALLER ICONS/TEXT)
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
        child: Stack(
          children: [
            // Decorative Circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ✅ CENTERED CONTENT
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ICON (Reduced from 36 to 30)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 30, color: Colors.white),
                    ),
                    const SizedBox(height: 10),

                    // TEXT (Reduced from 18 to 15)
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15, // ✅ Much safer size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
