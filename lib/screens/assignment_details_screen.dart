// assignment_details_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_session.dart';
import '../config/api_endpoints.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  final String classId;
  final String assignmentId;

  const AssignmentDetailsScreen({
    super.key,
    required this.classId,
    required this.assignmentId,
  });

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState
    extends State<AssignmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String? error;

  Map<String, dynamic>? assignmentInfo;
  Map<String, dynamic>? dashboard;
  List<dynamic> students = [];
  String? assignmentFileUrl;

  String selectedFilter = "All";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    fetchDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> fetchDetails() async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.getAssignmentDetails),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken ?? ""}",
        },
        body: jsonEncode({
          "class_id": widget.classId,
          "assignment_id": widget.assignmentId,
        }),
      );

      if (!mounted) return;

      final decoded = jsonDecode(response.body);
      final bodyData = decoded["body"] is String
          ? jsonDecode(decoded["body"])
          : decoded["body"] ?? decoded;

      if (response.statusCode != 200) {
        setState(() {
          error = bodyData is Map
              ? bodyData["error"] ?? "Failed to load assignment details"
              : "Failed to load assignment details";
          isLoading = false;
        });
        return;
      }

      String? extractedUrl;

      if (bodyData["assignment_file"] is Map) {
        extractedUrl = bodyData["assignment_file"]["url"];
      }

      setState(() {
        assignmentInfo = Map<String, dynamic>.from(
          bodyData["assignment_info"] ?? {},
        );
        dashboard = Map<String, dynamic>.from(
          bodyData["dashboard"] ?? {},
        );
        students = bodyData["students"] ?? [];
        assignmentFileUrl = extractedUrl;
        isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = "Something went wrong";
        isLoading = false;
      });
    }
  }

  Future<void> _openAssignmentFile() async {
    if (assignmentFileUrl == null) return;

    final uri = Uri.parse(assignmentFileUrl!);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open assignment file")),
      );
    }
  }

  bool _isSubmittedStatus(String status) {
    return status == "submitted" || status == "evaluated";
  }

  bool _isEvaluatedStatus(String status) {
    return status == "evaluated";
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = _asInt(dashboard?["total_students"]);
    final submitted = _asInt(dashboard?["total_submissions"]);
    final notSubmitted = totalStudents - submitted;

    final submissionRate = _asDouble(dashboard?["submission_rate"]);
    final avgScore = _asDouble(dashboard?["average_score"]);
    final aiPercent = _asDouble(dashboard?["average_ai_percentage"]);
    final maxScore = _asDouble(dashboard?["max_score"]);
    final highestPlag = _asDouble(dashboard?["highest_plagiarism"]);

    final filteredStudents = students.where((student) {
      final status = student["status"] ?? "not_submitted";
      final submittedStatus = _isSubmittedStatus(status);

      if (selectedFilter == "All") return true;
      if (selectedFilter == "Submitted") return submittedStatus;
      if (selectedFilter == "Not Submitted") return !submittedStatus;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Assignment Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignmentInfo?["topic"] ?? "",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Deadline: ${assignmentInfo?["deadline"] ?? ""}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (assignmentFileUrl != null)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB8829E),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _openAssignmentFile,
                                icon: const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  "Open Assignment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          const Text(
                            "Overview",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.2,
                            children: [
                              _statCard(
                                "Total Students",
                                totalStudents.toString(),
                                Icons.people,
                                Colors.blue,
                              ),
                              _statCard(
                                "Submitted",
                                submitted.toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                              _statCard(
                                "Not Submitted",
                                notSubmitted.toString(),
                                Icons.cancel,
                                Colors.red,
                              ),
                              _statCard(
                                "Submission Rate",
                                "${submissionRate.toStringAsFixed(1)}%",
                                Icons.analytics,
                                Colors.deepPurple,
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Performance Insights",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _tableRow(
                                  "Average Score",
                                  avgScore.toStringAsFixed(2),
                                ),
                                _divider(),
                                _tableRow(
                                  "AI %",
                                  "${aiPercent.toStringAsFixed(2)}%",
                                ),
                                _divider(),
                                _tableRow(
                                  "Max Score",
                                  maxScore.toStringAsFixed(2),
                                ),
                                _divider(),
                                _tableRow(
                                  "Highest Plagiarism",
                                  "${highestPlag.toStringAsFixed(2)}%",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Students",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              _filterButton("All"),
                              const SizedBox(width: 8),
                              _filterButton("Submitted"),
                              const SizedBox(width: 8),
                              _filterButton("Not Submitted"),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _studentsHeader(),
                                ...filteredStudents.map((student) {
                                  final status =
                                      student["status"] ?? "not_submitted";
                                  final submitted =
                                      _isSubmittedStatus(status);
                                  final evaluated =
                                      _isEvaluatedStatus(status);

                                  return _studentRow(
                                    student["name"] ?? "",
                                    submitted,
                                    evaluated,
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _filterButton(String label) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB8829E)
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _tableRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE8E8EC),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Student Name",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Status",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _studentRow(
    String name,
    bool submitted,
    bool evaluated,
  ) {
    final bgColor = evaluated
        ? const Color(0xFFE8F0FE)
        : submitted
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2);

    final textColor = evaluated
        ? const Color(0xFF1565C0)
        : submitted
            ? Colors.green
            : Colors.red;

    final label = evaluated
        ? "Evaluated"
        : submitted
            ? "Submitted"
            : "Not Submitted";

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name)),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
