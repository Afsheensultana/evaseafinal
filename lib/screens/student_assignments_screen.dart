import 'package:flutter/material.dart';

class StudentAssignmentsScreen extends StatelessWidget {
  final String className;

  const StudentAssignmentsScreen({
    super.key,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// ONGOING ASSIGNMENTS
            const Text(
              "Ongoing Assignments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _assignmentTile("Assignment 1"),
            _assignmentTile("Assignment 2"),

            const SizedBox(height: 24),

            /// PREVIOUS ASSIGNMENTS
            const Text(
              "Previous Assignments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _assignmentTile("Assignment A"),
            _assignmentTile("Assignment B"),
          ],
        ),
      ),
    );
  }

  Widget _assignmentTile(String title) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 🔒 Logic intentionally kept empty (future use)
        },
      ),
    );
  }
}
