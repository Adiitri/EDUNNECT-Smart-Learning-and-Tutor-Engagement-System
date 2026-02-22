import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ✅ NEW IMPORTS: Added to handle session and navigation to the new profile screen
import '../../services/user_session.dart';
import 'complete_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to track the selected role
  String _selectedRole = "student";
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Send the dynamically selected role to the backend
      final response = await http.post(
        Uri.parse(
          "http://127.0.0.1:5000/api/auth/register",
        ), // Use 127.0.0.1 for Chrome!
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "role": _selectedRole,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ UPDATED: Log the user in automatically and send to Profile Setup!
        final responseData = jsonDecode(response.body);
        UserSession.currentUser = responseData['user'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created!"),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Complete Profile, flagged as a New User
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CompleteProfileScreen(isNewUser: true),
            ),
          );
        }
      } else {
        final msg = jsonDecode(response.body)['msg'] ?? "Signup failed";
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error connecting to server. Is it running?"),
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
        title: const Text("Create Account"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Join Edunnect",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // 3-Role Selector UI (Student, Tutor, Admin)
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      "Student",
                      Icons.school_rounded,
                      "student",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRoleCard("Tutor", Icons.work_rounded, "tutor"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRoleCard(
                      "Admin",
                      Icons.admin_panel_settings_rounded,
                      "admin",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_rounded),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_rounded),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_rounded),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 112, 68, 255),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET FOR ROLE SELECTION ---
  Widget _buildRoleCard(String title, IconData icon, String roleValue) {
    bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ), // Slightly reduced padding
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28, // Slightly reduced icon size to fit 3 items
              color: isSelected ? Colors.blueAccent : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13, // Slightly reduced font size to prevent overflow
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blueAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
