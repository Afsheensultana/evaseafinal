import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import 'parent_dashboard.dart';
import 'parent_signup_screen.dart';
import '../utils/app_session.dart'; // ✅ ADDED

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

  // ---------------- JWT DECODE ----------------
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded);
  }

  // ---------------- LOGIN ----------------
  Future<void> _login() async {
    setState(() => isLoading = true);

    try {
      final response = await AuthService.login(
        role: null,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        _showMessage("Invalid credentials");
        return;
      }

      // -------- Parse outer JSON --------
      final Map<String, dynamic> outerJson = jsonDecode(response.body);

      if (!outerJson.containsKey('body')) {
        _showMessage("Invalid credentials");
        return;
      }

      // -------- Parse inner body --------
      final Map<String, dynamic> innerBody =
          jsonDecode(outerJson['body']);

      final String? accessToken = innerBody['access_token'];

      if (accessToken == null || accessToken.isEmpty) {
        _showMessage("Invalid credentials");
        return;
      }

      // ✅ FIX: STORE TOKEN FOR FUTURE APIS
      AppSession.token = accessToken;

      // -------- Decode JWT --------
      final decodedToken = _decodeJwt(accessToken);
      final String? role =
          decodedToken['role'] ?? decodedToken['custom:role'];

      if (role == null) {
        _showMessage("Role not found");
        return;
      }

      // -------- Navigate by role --------
      Widget target;

      switch (role) {
        case 'student':
          target = const StudentDashboard();
          break;
        case 'faculty':
          target = const FacultyDashboard();
          break;
        case 'parent':
          target = const ParentDashboard();
          break;
        default:
          _showMessage("Unknown role");
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
    } catch (e) {
      _showMessage("Login failed");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------------- UI HELPERS ----------------
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

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset(
              'assets/images/logo.png',
              height: 240,
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
