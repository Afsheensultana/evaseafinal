import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'parent_confirm_email_screen.dart'; // We reuse this generic screen for confirm email

class FacultySignupScreen extends StatefulWidget {
  const FacultySignupScreen({super.key});

  @override
  State<FacultySignupScreen> createState() => _FacultySignupScreenState();
}

class _FacultySignupScreenState extends State<FacultySignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final collegeController = TextEditingController();
  final collegeScodeController = TextEditingController();
  final departmentController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  final AuthService authService = AuthService();

  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
  );

  void _showPasswordPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Password Requirements"),
        content: const Text(
          "Password must be at least 8 characters and include:\n\n"
          "• One uppercase letter\n"
          "• One lowercase letter\n"
          "• One number\n"
          "• One special character (@ \$ ! % * ? &)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Got it",
              style: TextStyle(color: Color(0xFF50E3C2)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final res = await authService.facultySignup({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "college_name": collegeController.text.trim(),
        "college_scode": collegeScodeController.text.trim(),
        "department": departmentController.text.trim(),
        "role": "faculty"
      });

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful. OTP sent to email."),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentConfirmEmailScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        _show(data['error'] ?? "Signup failed");
      }
    } catch (e) {
      _show("Signup failed. Try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    collegeController.dispose();
    collegeScodeController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text("Faculty Signup"),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E8EC)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(30, 42, 74, 0.06),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(emailController, "Email"),
                  _passwordField(),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _showPasswordPopup,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF3BA18B),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Password requirements",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3BA18B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _field(nameController, "Full Name"),
                  _field(phoneController, "Phone Number"),
                  _field(collegeController, "College Name"),
                  _field(departmentController, "Department"),
                  
                  // Highlighted SCODE field for faculty
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: collegeScodeController,
                      decoration: InputDecoration(
                        labelText: "College Secret Code (SCODE)",
                        filled: true,
                        fillColor: const Color(0xFFF1FAF8), // light teal tint
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF50E3C2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF3BA18B), width: 1.5),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Secret Code is required" : null,
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3BA18B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor:
                            const Color.fromRGBO(80, 227, 194, 0.4),
                      ),
                      onPressed: isLoading ? null : register,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Create Faculty Account",
                              style: TextStyle(
                                color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        _show("Please enter your email up top to verify");
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ParentConfirmEmailScreen(email: email),
                        ),
                      );
                    },
                    child: const Text(
                      "Already registered? Verify!",
                      style: TextStyle(
                        color: Color(0xFF3BA18B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF3BA18B), width: 1.5),
          ),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: "Password",
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF3BA18B), width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: const Color(0xFF8A90A8),
            ),
            onPressed: () =>
                setState(() => isPasswordVisible = !isPasswordVisible),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Password is required";
          }
          if (!_passwordRegex.hasMatch(v)) {
            return "Required: Upper, Lower, Number, Special. Min 8 chars.";
          }
          return null;
        },
      ),
    );
  }
}
