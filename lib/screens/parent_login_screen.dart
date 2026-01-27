import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/dialogs.dart';
import 'parent_dashboard.dart';
import 'parent_signup_screen.dart';
import 'dart:convert';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  void login() async {
  final res = await AuthService.parentLogin(
    email: email.text,
    password: password.text,
  );

  final data = jsonDecode(res.body);

  if (res.statusCode != 200 ||
      !data.containsKey("access_token") ||
      data["access_token"].toString().isEmpty) {
    showInfoDialog(context, "Invalid email or password");
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const ParentDashboard(),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParentSignupScreen()),
                );
              },
              child: const Text("Not registered? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}