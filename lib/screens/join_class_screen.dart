import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/backend_service.dart';
import '../utils/app_session.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _classCodeCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  bool _loading = false;

  final _service = BackendService();

  Future<void> _join() async {
    if (_classCodeCtrl.text.trim().isEmpty || _tokenCtrl.text.trim().isEmpty) {
      _show("Class code and token are required");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await _service.joinClass(
        classCode: _classCodeCtrl.text.trim(),
        token: _tokenCtrl.text.trim(),
        studentId: AppSession.id ?? AppSession.email ?? "student-id",
        studentName: AppSession.name ?? "Student",
        studentEmail: AppSession.email ?? "",
        year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
        section: _sectionCtrl.text.trim().isEmpty ? null : _sectionCtrl.text.trim(),
      );

      final decoded = jsonDecode(res.body);
      final body = decoded["body"] is String ? jsonDecode(decoded["body"]) : decoded["body"] ?? decoded;

      if (res.statusCode == 200 && (body["error"] == null)) {
        _show("Joined class successfully");
        if (mounted) Navigator.pop(context, true);
      } else {
        _show(body["error"]?.toString() ?? "Failed to join class");
      }
    } catch (_) {
      _show("Unable to join class right now");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _field(TextEditingController c, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text("Join Class"),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E8EC)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(30, 42, 74, 0.05),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFB8829E).withValues(alpha: 0.15),
                    child: const Icon(Icons.group_add, color: Color(0xFFB8829E)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Enter your class invite details",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1D2B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Use the class code and secure token shared by your faculty.",
                style: TextStyle(
                  color: Color(0xFF5A6078),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _field(_classCodeCtrl, "Class Code", required: true),
              _field(_tokenCtrl, "Join Token", required: true),
              _field(_yearCtrl, "Year"),
              _field(_sectionCtrl, "Section"),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8829E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Join"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
