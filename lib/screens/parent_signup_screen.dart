import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'parent_login_screen.dart';

class ParentSignupScreen extends StatefulWidget {
  const ParentSignupScreen({super.key});

  @override
  State<ParentSignupScreen> createState() => _ParentSignupScreenState();
}

class _ParentSignupScreenState extends State<ParentSignupScreen> {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final studentController = TextEditingController();
  final collegeController = TextEditingController();

  final AuthService authService = AuthService();

  Future<void> register() async {
    try {
      final res = await authService.parentSignup({
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "name": nameController.text.trim(),
        "student_name": studentController.text.trim(),
        "college": collegeController.text.trim(),
      });

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ParentLoginScreen(),
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: studentController, decoration: const InputDecoration(labelText: "Student Name")),
            TextField(controller: collegeController, decoration: const InputDecoration(labelText: "College")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
