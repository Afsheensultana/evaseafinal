import 'package:flutter/material.dart';

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

            // ✅ DEADLINE PICKER
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
                onPressed: () {
                  // 🔥 GENERATE ASSIGNMENT API CALL
                  print("Topic: ${topicCtrl.text}");
                  print("Deadline: $selectedDeadline");
                  print("Generate Assignment Clicked");
                },
                child: const Text("Generate Assignment"),
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