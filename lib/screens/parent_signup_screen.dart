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

  bool isLoading = false;

  Future<void> register() async {
    setState(() => isLoading = true);

    final response = await AuthService.parentSignup({
      "email": emailController.text,
      "phone": phoneController.text,
      "name": nameController.text,
      "student_name": studentController.text,
      "college_name": collegeController.text,
    });

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Parent Name"),
            ),
            TextField(
              controller: studentController,
              decoration: const InputDecoration(labelText: "Student Name"),
            ),
            TextField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: "College Name"),
            ),

            const SizedBox(height: 20),

            /// REGISTER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                child: const Text("Register"),
              ),
            ),

            const SizedBox(height: 12),

            /// 👇 THIS WAS MISSING — NOW FIXED
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already registered? "),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentLoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}