import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/backend_service.dart';

class FacultyToolsScreen extends StatefulWidget {
  final String classId;

  const FacultyToolsScreen({super.key, required this.classId});

  @override
  State<FacultyToolsScreen> createState() => _FacultyToolsScreenState();
}

class _FacultyToolsScreenState extends State<FacultyToolsScreen> {
  final _service = BackendService();

  final _topicCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _studentMailCtrl = TextEditingController();
  final _assnNameCtrl = TextEditingController();
  final _filePathCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _sendMail() async {
    setState(() => _loading = true);
    try {
      final batchRes = await _service.getBatchMails();
      final decodedBatch = jsonDecode(batchRes.body);
      final batchBody = decodedBatch["body"] is String ? jsonDecode(decodedBatch["body"]) : decodedBatch["body"] ?? decodedBatch;
      final recipients = (batchBody[widget.classId] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      final res = await _service.sendAssignmentMail(
        recipients: recipients,
        subject: _subjectCtrl.text.trim().isEmpty ? "Assignment Notification" : _subjectCtrl.text.trim(),
        message: _msgCtrl.text.trim().isEmpty ? "Please complete your assignment on time." : _msgCtrl.text.trim(),
        topic: _topicCtrl.text.trim(),
        deadline: _deadlineCtrl.text.trim(),
        extension: "pdf",
        classCode: widget.classId,
      );
      final decoded = jsonDecode(res.body);
      final body = decoded["body"] is String ? jsonDecode(decoded["body"]) : decoded["body"] ?? decoded;
      _show(body["message"]?.toString() ?? "Mail API called");
    } catch (_) {
      _show("Mail dispatch failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _viewLatest() async {
    setState(() => _loading = true);
    try {
      final res = await _service.viewAssignment(classCode: widget.classId, topic: _topicCtrl.text.trim());
      final decoded = jsonDecode(res.body);
      final body = decoded["body"] is String ? jsonDecode(decoded["body"]) : decoded["body"] ?? decoded;
      final url = body["url"]?.toString();
      if (url == null || url.isEmpty) {
        _show("No file link found");
      } else {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _show("Unable to open latest assignment");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _evaluate() async {
    if (_filePathCtrl.text.trim().isEmpty || _studentMailCtrl.text.trim().isEmpty || _assnNameCtrl.text.trim().isEmpty) {
      _show("File URL, student email and assignment filename are required");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _service.evaluateAssignment(
        filePath: _filePathCtrl.text.trim(),
        studentName: _studentMailCtrl.text.trim(),
        assignmentName: _assnNameCtrl.text.trim(),
        batchName: widget.classId,
      );
      final decoded = jsonDecode(res.body);
      final body = decoded["body"] is String ? jsonDecode(decoded["body"]) : decoded["body"] ?? decoded;
      _show(body["message"]?.toString() ?? body["error"]?.toString() ?? "Evaluate API called");
    } catch (_) {
      _show("Evaluation failed");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field(TextEditingController c, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFFDFDFE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E8EC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB8829E), width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF5A6078)),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF1A1D2B),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text("Class Tools"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEFF5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(30, 42, 74, 0.04),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.12),
                    child: const Icon(Icons.class_, color: Color(0xFF00897B), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Class ID: ${widget.classId}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D2B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEFF5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(30, 42, 74, 0.05),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    icon: Icons.mail_outline_rounded,
                    title: "Mail + View",
                    color: const Color(0xFFB8829E),
                  ),
                  const SizedBox(height: 12),
                  _field(_topicCtrl, "Topic"),
                  _field(_deadlineCtrl, "Deadline (DDMMYY)"),
                  _field(_subjectCtrl, "Mail Subject"),
                  _field(_msgCtrl, "Mail Message", lines: 3),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _sendMail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8829E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text("Send Mail"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _viewLatest,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD5DAE4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              foregroundColor: const Color(0xFF4A5568),
                            ),
                            child: const Text("View Latest"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFEDEFF5)),
                  const SizedBox(height: 18),
                  _sectionHeader(
                    icon: Icons.analytics_outlined,
                    title: "Evaluate Submission",
                    color: Color(0xFF00897B),
                  ),
                  const SizedBox(height: 12),
                  _field(_filePathCtrl, "Submitted File URL"),
                  _field(_studentMailCtrl, "Student Email"),
                  _field(_assnNameCtrl, "Assignment Filename"),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _evaluate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Run Evaluation"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
