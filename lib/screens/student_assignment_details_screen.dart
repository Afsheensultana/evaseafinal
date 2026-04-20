import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api_endpoints.dart';
import '../utils/app_session.dart';

class StudentAssignmentDetailsScreen extends StatefulWidget {
  final String classId;
  final String assignmentId;

  const StudentAssignmentDetailsScreen({
    super.key,
    required this.classId,
    required this.assignmentId,
  });

  @override
  State<StudentAssignmentDetailsScreen> createState() =>
      _StudentAssignmentDetailsScreenState();
}

class _StudentAssignmentDetailsScreenState
    extends State<StudentAssignmentDetailsScreen> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getStudentAssignmentDetails),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken ?? ""}",
        },
        body: jsonEncode({
          "class_id": widget.classId,
          "assignment_id": widget.assignmentId,
        }),
      );

      final decoded = jsonDecode(response.body);
      final body = decoded["body"] is String
          ? jsonDecode(decoded["body"])
          : decoded["body"];

      if (response.statusCode != 200) {
        setState(() {
          error = body["error"] ?? "Failed to load details";
          isLoading = false;
        });
        return;
      }

      setState(() {
        data = Map<String, dynamic>.from(body);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Something went wrong";
        isLoading = false;
      });
    }
  }

  Future<void> openReport() async {
    final url = data?["evaluation_report_url"];
    if (url == null || url.toString().isEmpty) return;

    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final item = data;
    final status = item?["submission_status"] ?? "not_submitted";
    final isEvaluated = status == "evaluated";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Assignment Details"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item?["topic"] ?? "Assignment",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Deadline: ${item?["deadline"] ?? "N/A"}"),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isEvaluated
                                    ? const Color(0xFFE8F0FE)
                                    : const Color(0xFFE6F7EF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isEvaluated ? "Evaluated" : "Submitted",
                                style: TextStyle(
                                  color: isEvaluated
                                      ? const Color(0xFF1565C0)
                                      : const Color(0xFF16A34A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (isEvaluated)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Evaluation",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text("Score: ${item?["total_score"] ?? "-"}"),
                              const SizedBox(height: 8),
                              Text("AI Percentage: ${item?["ai_percentage"] ?? "-"}%"),
                              const SizedBox(height: 14),
                              if (item?["evaluation_report_url"] != null)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf_rounded),
                                    label: const Text("Open Report"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB8829E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: openReport,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Html(
                          data: item?["content_html"] ?? "",
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
