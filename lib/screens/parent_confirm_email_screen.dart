import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ParentConfirmEmailScreen extends StatefulWidget {
  final String email;

  const ParentConfirmEmailScreen({
    super.key,
    required this.email,
  });

  @override
  State<ParentConfirmEmailScreen> createState() =>
      _ParentConfirmEmailScreenState();
}

class _ParentConfirmEmailScreenState
    extends State<ParentConfirmEmailScreen> {
  final otpController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> confirmEmail() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _show("OTP is required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await authService.confirmParentEmail(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        _show("Email verified successfully");

        await Future.delayed(const Duration(milliseconds: 600));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        _show(
          data['error'] ??
              "OTP verification failed. Please check the code.",
        );
      }
    } catch (e) {
      _show("Verification failed. Try again.");
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
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Email")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "OTP has been sent to:",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : confirmEmail,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Confirm"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
