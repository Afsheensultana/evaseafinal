import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../utils/app_session.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen>
    with SingleTickerProviderStateMixin {

  final topicCtrl = TextEditingController();
  final beginnerCtrl = TextEditingController();
  final intermediateCtrl = TextEditingController();
  final advancedCtrl = TextEditingController();

  DateTime? selectedDeadline;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  // ================== API LOGIC (UNCHANGED) ==================

  Future<void> generateAssignment() async {
    if (selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a deadline")),
      );
      return;
    }

    if (AppSession.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.generateAssignment),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.token}",
        },
        body: jsonEncode({
          "topic": topicCtrl.text,
          "beginner": beginnerCtrl.text,
          "intermediate": intermediateCtrl.text,
          "advanced": advancedCtrl.text,
          "deadline": selectedDeadline!.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Assignment generated successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        title: const Text("Create Assignment"),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE8E8EC),
              ),
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

                /// TOPIC FIELD
                _field("Topic", topicCtrl, Icons.topic),

                /// 🔹 Static Info Text (No Popup)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFB8829E),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Enter number of questions you want to generate:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A90A8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _field("Beginner Level", beginnerCtrl, Icons.looks_one),
                _field("Intermediate Level",
                    intermediateCtrl, Icons.looks_two),
                _field("Advanced Level",
                    advancedCtrl, Icons.looks_3),

                const SizedBox(height: 16),

                /// DEADLINE
                InkWell(
                  onTap: _pickDeadline,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      prefixIcon: const Icon(
                        Icons.event,
                        color: Color(0xFFB8829E),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
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
                    child: Text(
                      selectedDeadline == null
                          ? "Select deadline"
                          : "${selectedDeadline!.day}-${selectedDeadline!.month}-${selectedDeadline!.year}",
                      style: const TextStyle(
                        color: Color(0xFF1A1D2B),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// GENERATE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                    ),
                    label: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Generate Assignment",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
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
                        isLoading ? null : generateAssignment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController ctrl,
      IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFB8829E),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
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
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }
}
