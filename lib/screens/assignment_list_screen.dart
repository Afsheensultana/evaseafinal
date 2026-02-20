import 'package:flutter/material.dart';

class AssignmentListScreen extends StatelessWidget {
  final String title;
  final bool isOngoing;

  const AssignmentListScreen({
    super.key,
    required this.title,
    required this.isOngoing,
  });

  @override
  Widget build(BuildContext context) {

    final assignments = isOngoing
        ? ["Assignment 1", "Assignment 2"]
        : ["Assignment A", "Assignment B"];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            return _assignmentTile(assignments[index]);
          },
        ),
      ),
    );
  }

  Widget _assignmentTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8E8EC),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 42, 74, 0.05),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1D2B),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF8A90A8),
        ),
      ),
    );
  }
}
