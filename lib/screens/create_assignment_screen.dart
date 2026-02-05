import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../utils/app_session.dart'; // ✅ ADDED

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final topicCtrl = TextEditingController();
  final beginnerCtrl = TextEditingController();
  final intermediateCtrl = TextEditingController();
  final advancedCtrl = TextEditingController();

  DateTime? selectedDeadline;
  bool isLoading = false;

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
          "Authorization": "Bearer ${AppSession.token}", // ✅ FIX
        },
        body: jsonEncode({
          "topic": topicCtrl.text,
          "beginner": beginnerCtrl.text,
          "intermediate": intermediateCtrl.text,
          "advanced": advancedCtrl.text,
          "deadline": selectedDeadline!.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assignment generated successfully")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assignment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field("Topic", topicCtrl),
            _field("Beginner Level", beginnerCtrl),
            _field("Intermediate Level", intermediateCtrl),
            _field("Advanced Level", advancedCtrl),

            const SizedBox(height: 12),

            InkWell(
              onTap: _pickDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Deadline",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  selectedDeadline == null
                      ? "Select deadline"
                      : "${selectedDeadline!.day}-${selectedDeadline!.month}-${selectedDeadline!.year}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : generateAssignment,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Generate Assignment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }
}
