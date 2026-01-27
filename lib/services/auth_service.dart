import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';

class AuthService {
  /// Student / Faculty Login
  static Future<http.Response> login({
    required String role,
    required String email,
    required String password,
  }) async {
    final String url = role == "student"
        ? ApiEndpoints.studentLogin
        : ApiEndpoints.facultyLogin;

    return await http.post(
      Uri.parse(url),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );
  }

  /// Parent Login
  static Future<http.Response> parentLogin({
    required String email,
    required String password,
  }) async {
    return await http.post(
      Uri.parse(ApiEndpoints.parentLogin),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );
  }

  /// Parent Signup
  static Future<http.Response> parentSignup(
      Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(ApiEndpoints.parentSignup),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }
}