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
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text("Confirm Email"),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "OTP has been sent to:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A6078),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1D2B),
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
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

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
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
                        isLoading ? null : confirmEmail,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Confirm",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                                  color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
