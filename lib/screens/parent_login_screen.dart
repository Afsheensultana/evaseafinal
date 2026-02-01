import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'parent_dashboard.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> login() async {
    try {
      final res = await authService.loginParent(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      final Map<String, dynamic> data = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200 &&
          data.containsKey("access_token") &&
          data["access_token"] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ParentDashboard(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
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
      appBar: AppBar(title: const Text("Parent Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
