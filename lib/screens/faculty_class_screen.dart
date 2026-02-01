import 'package:flutter/material.dart';
import 'create_assignment_screen.dart';

class FacultyClassScreen extends StatelessWidget {
  final String className;

  const FacultyClassScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(className)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ongoing Assignments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _assignmentTile("Assignment 1"),
            _assignmentTile("Assignment 2"),

            const SizedBox(height: 20),

            const Text("Previous Assignments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _assignmentTile("Assignment A"),
            _assignmentTile("Assignment B"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAssignmentScreen(),
                    ),
                  );
                },
                child: const Text("Create Assignment"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: START ATTENDANCE API
                },
                child: const Text("Start Attendance"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentTile(String title) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}