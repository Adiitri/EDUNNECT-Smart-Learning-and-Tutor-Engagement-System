import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../services/user_session.dart';
import '../student/student_dashboard.dart';
import '../tutor/tutor_dashboard.dart';
import '../admin/admin_dashboard.dart';

class CompleteProfileScreen extends StatefulWidget {
  final bool isNewUser; // Helps us decide where to navigate after saving

  const CompleteProfileScreen({super.key, this.isNewUser = false});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _classController =
      TextEditingController(); // For Students
  final TextEditingController _expertiseController =
      TextEditingController(); // For Tutors

  bool _isLoading = false;
  late String _userRole;
  late String _userId;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if it exists in the session
    final user = UserSession.currentUser;
    _userId = user?['_id'] ?? '';
    _userRole = user?['role'] ?? 'student';

    _phoneController.text = user?['phone'] ?? '';
    _locationController.text = user?['location'] ?? '';
    _aboutController.text = user?['about'] ?? '';
    _expertiseController.text = user?['expertise'] ?? '';
    _classController.text = user?['classGrade'] ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(
          "http://127.0.0.1:5000/api/auth/update",
        ), // Adjust route as needed
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": _userId,
          "phone": _phoneController.text,
          "location": _locationController.text,
          "about": _aboutController.text, // Used for 'Subjects of Interest'
          "classGrade": _classController.text,
          "expertise": _expertiseController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // Update local session data
        final updatedData = jsonDecode(response.body)['user'];
        UserSession.currentUser = updatedData;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile Saved!"),
              backgroundColor: Colors.green,
            ),
          );

          // If they just registered, take them to their dashboard
          if (widget.isNewUser) {
            if (_userRole == 'student') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentDashboard()),
              );
            } else if (_userRole == 'tutor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TutorDashboard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboard()),
              );
            }
          } else {
            // If they opened this from the dashboard, just go back
            Navigator.pop(context);
          }
        }
      } else {
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error saving profile."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.isNewUser ? "Complete Your Profile" : "Edit Profile",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF4A00E0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tell us a bit about yourself",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This helps us personalize your experience.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            _buildTextField(
              "Phone Number",
              Icons.phone_rounded,
              _phoneController,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              "Location / City",
              Icons.location_on_rounded,
              _locationController,
            ),
            const SizedBox(height: 16),

            // DYNAMIC FIELD: Only show Class if Student
            if (_userRole == 'student') ...[
              _buildTextField(
                "Class / Grade (e.g. 10th, College)",
                Icons.school_rounded,
                _classController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Subjects of Interest",
                Icons.menu_book_rounded,
                _aboutController,
                maxLines: 3,
              ),
            ],

            // DYNAMIC FIELD: Only show Expertise if Tutor
            if (_userRole == 'tutor') ...[
              _buildTextField(
                "Your Expertise (e.g. Math, Python)",
                Icons.workspace_premium_rounded,
                _expertiseController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Bio / About You",
                Icons.person_outline_rounded,
                _aboutController,
                maxLines: 3,
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isNewUser
                            ? "Save & Go to Dashboard"
                            : "Save Changes",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // Skip button for new users
            if (widget.isNewUser) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (_userRole == 'student') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentDashboard(),
                        ),
                      );
                    } else if (_userRole == 'tutor') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TutorDashboard(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Skip for now",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 45.0 : 0,
          ), // Align icon to top if multi-line
          child: Icon(icon, color: Colors.deepPurpleAccent),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }
}
