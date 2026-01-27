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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  // ✅ ROLE STATE (DECLARED ONCE – CORRECT PLACE)
  String selectedRole = "student";

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
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    final response = await AuthService.login(
      role: selectedRole,
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() => isLoading = false);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        !data.containsKey("access_token") ||
        data["access_token"].toString().isEmpty) {
      _showMessage("Invalid email or password");
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            selectedRole == "student"
                ? const StudentDashboard()
                : const FacultyDashboard(),
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            /// ✅ LOGO (ASSET KEPT)
            Image.asset(
  'assets/images/logo.png',
  height: 240,
),

            const SizedBox(height: 20),

            /// ✅ SIMPLE ROLE DROPDOWN (NOT BOXED)
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

            /// EMAIL
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// PASSWORD WITH SHOW / HIDE
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

            /// FORGOT (LEFT) + PARENT (RIGHT)
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
                        builder: (_) =>
                            const ParentSignupScreen(),
                      ),
                    );
                  },
                  child: const Text("Are you a parent?"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// LOGIN BUTTON
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