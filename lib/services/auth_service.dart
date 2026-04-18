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

  // ---------- STUDENT SIGNUP ----------
  Future<http.Response> studentSignup(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(ApiEndpoints.studentSignup),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // ---------- FACULTY SIGNUP ----------
  Future<http.Response> facultySignup(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(ApiEndpoints.facultySignup),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // ---------- ✅ CONFIRM EMAIL ----------
  Future<http.Response> confirmEmail({
    required String email,
    required String otp,
  }) async {
    // Both Parent, Student, and Faculty use this endpoint
    return await http.post(
      Uri.parse(ApiEndpoints.parentConfirmEmail), // parentConfirmEmail works for all because of common pool!
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
  }

  Future<http.Response> confirmPhone({
    required String email,
    required String otp,
  }) async {
    return await http.post(
      Uri.parse(ApiEndpoints.confirmPhone),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );
  }

  Future<http.Response> finalizeSignup({required String email}) async {
    return await http.post(
      Uri.parse(ApiEndpoints.finalizeSignup),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
  }

  Future<http.Response> logout({required String email, required String token}) async {
    return await http.post(
      Uri.parse(ApiEndpoints.logout),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"email": email}),
    );
  }
}
