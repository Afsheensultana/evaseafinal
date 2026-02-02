import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import 'parent_signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  String selectedRole = "student";

Future<void> _login() async {
  setState(() => isLoading = true);

  try {
    final response = await AuthService.login(
      role: selectedRole,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!mounted) return;

    print("STATUS: ${response.statusCode}");
    print("RAW BODY: ${response.body}");

    final Map<String, dynamic> outerJson = jsonDecode(response.body);

    // 🔥 VERY IMPORTANT: decode body AGAIN
    final Map<String, dynamic> innerBody =
        jsonDecode(outerJson['body']);

    final String? accessToken = innerBody['access_token'];
    final String? idToken = innerBody['id_token'];

    if (accessToken != null && idToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => selectedRole == "student"
              ? const StudentDashboard()
              : const FacultyDashboard(),
        ),
      );
    } else {
      _showMessage("Invalid credentials");
    }
  } catch (e) {
    print("LOGIN ERROR: $e");
    if (!mounted) return;
    _showMessage("Login failed");
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}




  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _forgotPasswordPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Forgot Password"),
        content: const Text("Contact your college administration"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            /// LOGO (UNCHANGED)
            Image.asset(
              'assets/images/logo.png',
              height: 240,
            ),

            const SizedBox(height: 20),

            /// ROLE DROPDOWN (UNCHANGED)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Login as: "),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(
                      value: "student",
                      child: Text("Student"),
                    ),
                    DropdownMenuItem(
                      value: "faculty",
                      child: Text("Faculty"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _forgotPasswordPopup,
                  child: const Text("Forgot Password?"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentSignupScreen(),
                      ),
                    );
                  },
                  child: const Text("Are you a parent?"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
