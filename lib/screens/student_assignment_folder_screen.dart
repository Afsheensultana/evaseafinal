import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/app_session.dart';
import '../config/api_endpoints.dart';

class StudentAssignmentFolderScreen extends StatefulWidget {
  final String title;
  final String type;
  final String classId;

  const StudentAssignmentFolderScreen({
    super.key,
    required this.title,
    required this.type,
    required this.classId,
  });

  @override
  State<StudentAssignmentFolderScreen> createState() =>
      _StudentAssignmentFolderScreenState();
}

class _StudentAssignmentFolderScreenState
    extends State<StudentAssignmentFolderScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> assignments = [];
  bool isLoading = true;
  bool isUploading = false;
  String? error;

  // 🔥 NEW VARIABLES
  File? selectedFile;
  String? selectedFileName;
  String? selectedAssignmentId;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    fetchAssignments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= FETCH =================
  Future<void> fetchAssignments() async {
    try {
      final authToken = AppSession.idToken ?? AppSession.token;
      final response = await http.post(
        Uri.parse(ApiEndpoints.getStudentAssignments),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode({
          "class_id": widget.classId,
        }),
      );

      debugPrint("[StudentAssignmentFolder] status=${response.statusCode}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200) {
        // Handle error - try both wrapped and unwrapped
        Map<String, dynamic> errBody = {};
        if (decoded is Map<String, dynamic> && decoded.containsKey("body")) {
          final rawBody = decoded["body"];
          errBody = rawBody is String ? jsonDecode(rawBody) : rawBody ?? {};
        } else if (decoded is Map<String, dynamic>) {
          errBody = decoded;
        }
        setState(() {
          error = errBody["error"] ?? "Server error";
          isLoading = false;
        });
        return;
      }

      // Handle both wrapped {"body": ...} and unwrapped formats
      final Map<String, dynamic> bodyData;
      if (decoded is Map<String, dynamic> && decoded.containsKey("body")) {
        final rawBody = decoded["body"];
        bodyData = rawBody is String
            ? Map<String, dynamic>.from(jsonDecode(rawBody))
            : Map<String, dynamic>.from(rawBody);
      } else if (decoded is Map<String, dynamic>) {
        bodyData = decoded;
      } else {
        throw FormatException("Unexpected response format");
      }

      final List<dynamic> list =
          bodyData[widget.type] ?? [];

      setState(() {
        assignments = list
            .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e))
            .toList();
        isLoading = false;
      });

      _controller.forward();

    } catch (e) {
      debugPrint("[StudentAssignmentFolder] ERROR: $e");
      setState(() {
        error = "Failed to load assignments";
        isLoading = false;
      });
    }
  }

  // ================= PICK FILE =================
  Future<void> _pickFile(String assignmentId) async {

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result == null) return;

    setState(() {
      selectedFile = File(result.files.single.path!);
      selectedFileName = result.files.single.name;
      selectedAssignmentId = assignmentId;
    });
  }

  // ================= CONFIRM + UPLOAD =================
  Future<void> _confirmUpload() async {

    if (selectedFile == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Upload"),
          content: const Text(
              "Please check your file before uploading.\nDo you want to continue?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("Upload"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => isUploading = true);

    final bytes = await selectedFile!.readAsBytes();
    final encodedFile = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(ApiEndpoints.submitAssignment),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AppSession.idToken ?? ""}",
      },
      body: jsonEncode({
        "file": encodedFile,
        "filename": selectedFileName ?? "submission.pdf",
        "metadata": {
          "email": AppSession.email ?? "",
          "class_code": widget.classId,
          "assignment_name": selectedAssignmentId ?? "",
        },
      }),
    );

    setState(() {
      isUploading = false;
      selectedFile = null;
      selectedFileName = null;
      selectedAssignmentId = null;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Successful")),
      );
      fetchAssignments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Failed")),
      );
    }
  }

  // ================= SHIMMER =================
  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),

      body: Stack(
        children: [

          isLoading
              ? _buildShimmer()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {

                        final item = assignments[index];
                        final topic = item["topic"] ?? "";
                        final deadline = item["deadline"] ?? "";
                        final submissionStatus =
                            item["submission_status"] ?? "not_submitted";
                        final isSubmitted =
                            submissionStatus == "submitted";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFF9FBFF),
                              ],
                            ),
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
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSubmitted
                                          ? const Color(0xFFE6F7EF)
                                          : const Color(0xFFEAF2FF),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      isSubmitted
                                          ? Icons.check_circle
                                          : Icons.assignment,
                                      color: isSubmitted
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF3B82F6),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(topic,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 16)),
                                        const SizedBox(height: 6),
                                        Text("Deadline: $deadline"),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isSubmitted
                                                ? const Color(0xFFE6F7EF)
                                                : const Color(0xFFFFF4E6),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isSubmitted
                                                ? "Submitted"
                                                : "Not Submitted",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (widget.type == "ongoing")
                                    IconButton(
                                      icon: const Icon(
                                          Icons.cloud_upload_rounded),
                                      onPressed: () =>
                                          _pickFile(item["assignment_id"]),
                                    ),
                                ],
                              ),

                              // 🔥 SHOW SELECTED FILE
                              if (selectedAssignmentId ==
                                      item["assignment_id"] &&
                                  selectedFileName != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Selected: $selectedFileName",
                                        style: const TextStyle(
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: _confirmUpload,
                                        child:
                                            const Text("Upload File"),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
