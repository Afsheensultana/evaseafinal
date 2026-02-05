import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'parent_confirm_email_screen.dart';

class ParentSignupScreen extends StatefulWidget {
  const ParentSignupScreen({super.key});

  @override
  State<ParentSignupScreen> createState() => _ParentSignupScreenState();
}

class _ParentSignupScreenState extends State<ParentSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final studentController = TextEditingController();
  final collegeController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  final AuthService authService = AuthService();

  /// 🔐 PASSWORD REGEX
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
  );

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final res = await authService.parentSignup({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "student_name": studentController.text.trim(),
        "college": collegeController.text.trim(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Signup")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(emailController, "Email"),
                _passwordField(), // 👈 unchanged position
                _passwordHint(),  // 👈 popup text added BELOW password
                _field(nameController, "Name"),
                _field(phoneController, "Phone"),
                _field(studentController, "Student Name"),
                _field(collegeController, "College"),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register"),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      _show("Please enter your email to verify");
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
                  child: const Text("Already registered? Verify!"),
                ),
              ],
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
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
            v == null || v.trim().isEmpty ? "$label is required" : null,
      ),
    );
  }

  /// 🔐 PASSWORD FIELD WITH STRICT VALIDATION
  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: "Password",
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
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
            return "Invalid password format";
          }
          return null;
        },
      ),
    );
  }

  /// ℹ️ PASSWORD INFO POPUP (NON-BLOCKING)
  Widget _passwordHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              "Password must be at least 8 characters and include:\n"
              "• One uppercase letter\n"
              "• One lowercase letter\n"
              "• One number\n"
              "• One special character (@ \$ ! % * ? &)",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
