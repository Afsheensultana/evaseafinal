import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import 'parent_dashboard.dart';
import 'parent_signup_screen.dart';
import '../utils/app_session.dart';

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

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

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

      final Map<String, dynamic> outerJson = jsonDecode(response.body);

      if (!outerJson.containsKey('body')) {
        _showMessage("Invalid credentials");
        return;
      }

      final Map<String, dynamic> innerBody =
          jsonDecode(outerJson['body']);

      final String? accessToken = innerBody['access_token'];
      final String? idToken = innerBody['id_token']; // ✅ ADD THIS

      if (accessToken == null ||
          accessToken.isEmpty ||
          idToken == null ||
          idToken.isEmpty) {
        _showMessage("Invalid credentials");
        return;
      }

      // Store access token normally
      AppSession.token = accessToken;
      AppSession.idToken = idToken; 
      await saveToken(accessToken);

      // ✅ Decode ID token for role
      final decodedToken = _decodeJwt(idToken);

      final String? role =
          decodedToken['role'] ?? decodedToken['custom:role'];

      if (role == null) {
        _showMessage("Role not found");
        return;
      }

      Widget target;

      switch (role) {
        case 'student':
          target = const StudentDashboard();
          break;
        case 'faculty':
          target = FacultyDashboard(token: AppSession.token!);
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

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _forgotPasswordPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
      backgroundColor: const Color(0xFFFAFAFB),
      body: Stack(
        children: [
          // Subtle Aurora Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  center: Alignment(-0.6, -0.4),
                  colors: [
                    Color.fromRGBO(184, 130, 158, 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 80),

                Image.asset(
                  'assets/images/logo.png',
                  height: 250,
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE8E8EC),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(30, 42, 74, 0.06),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(
                            color: Color(0xFF5A6078),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8EC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB8829E),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(
                            color: Color(0xFF5A6078),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8EC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFB8829E),
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF8A90A8),
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible =
                                    !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _forgotPasswordPopup,
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  color: Color(0xFFB8829E)),
                            ),
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
                            child: const Text(
                              "Are you a parent?",
                              style: TextStyle(
                                  color: Color(0xFFB8829E)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFB8829E),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            shadowColor:
                                const Color.fromRGBO(
                                    184, 130, 158, 0.4),
                          ),
                          onPressed:
                              isLoading ? null : _login,
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                      fontWeight:
                                          FontWeight.w600,
                                      fontSize: 15),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
