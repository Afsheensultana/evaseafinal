import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';

class AuthService {
  // ---------- LOGIN ----------
  static Future<http.Response> login({
    String? role, // kept for UI compatibility
    required String email,
    required String password,
  }) async {
    return await http.post(
      Uri.parse(ApiEndpoints.studentLogin),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );
  }

  // ---------- PARENT SIGNUP ----------
  Future<http.Response> parentSignup(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(ApiEndpoints.parentSignup),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // ---------- ✅ PARENT CONFIRM EMAIL ----------
  Future<http.Response> confirmParentEmail({
    required String email,
    required String otp,
  }) async {
    return await http.post(
      Uri.parse(ApiEndpoints.parentConfirmEmail),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
  }
}
