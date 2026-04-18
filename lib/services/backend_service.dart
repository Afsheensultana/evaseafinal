import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../utils/app_session.dart';

class BackendService {
  Map<String, String> _jsonHeaders() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${AppSession.idToken ?? ""}",
    };
  }

  Future<http.Response> logout({required String email}) {
    return http.post(
      Uri.parse(ApiEndpoints.logout),
      headers: _jsonHeaders(),
      body: jsonEncode({"email": email}),
    );
  }

  Future<http.Response> joinClass({
    required String classCode,
    required String token,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? year,
    String? section,
  }) {
    return http.post(
      Uri.parse(ApiEndpoints.joinClass),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "class_code": classCode,
        "token": token,
        "student_id": studentId,
        "student_name": studentName,
        "student_email": studentEmail,
        "year": year,
        "section": section,
      }),
    );
  }

  Future<http.Response> getBatchMails() {
    return http.post(
      Uri.parse(ApiEndpoints.getBatchMails),
      headers: _jsonHeaders(),
      body: jsonEncode({}),
    );
  }

  Future<http.Response> sendAssignmentMail({
    required List<String> recipients,
    required String subject,
    required String message,
    required String topic,
    required String deadline,
    required String extension,
    String? classCode,
  }) {
    return http.post(
      Uri.parse(ApiEndpoints.sendAssignmentMail),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "recipients": recipients,
        "subject": subject,
        "message": message,
        "topic": topic,
        "deadline": deadline,
        "extension": extension,
        "class_code": classCode,
      }),
    );
  }

  Future<http.Response> evaluateAssignment({
    required String filePath,
    required String studentName,
    required String assignmentName,
    required String batchName,
  }) {
    return http.post(
      Uri.parse(ApiEndpoints.evaluateAssignment),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "file_path": filePath,
        "student_name": studentName,
        "assignment_name": assignmentName,
        "batch_name": batchName,
      }),
    );
  }

  Future<http.Response> viewAssignment({String? classCode, String? topic}) {
    return http.post(
      Uri.parse(ApiEndpoints.viewAssignment),
      headers: _jsonHeaders(),
      body: jsonEncode({
        "class_code": classCode,
        "topic": topic,
      }),
    );
  }

  Future<http.Response> retrieveAssignments({String? classId}) {
    return http.post(
      Uri.parse(ApiEndpoints.retrieveAssignments),
      headers: _jsonHeaders(),
      body: jsonEncode({"class_id": classId}),
    );
  }

  Future<http.Response> confirmPhone({required String email, required String otp}) {
    return http.post(
      Uri.parse(ApiEndpoints.confirmPhone),
      headers: _jsonHeaders(),
      body: jsonEncode({"email": email, "otp": otp}),
    );
  }

  Future<http.Response> finalizeSignup({required String email}) {
    return http.post(
      Uri.parse(ApiEndpoints.finalizeSignup),
      headers: _jsonHeaders(),
      body: jsonEncode({"email": email}),
    );
  }
}
