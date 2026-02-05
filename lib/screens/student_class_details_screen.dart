import 'package:flutter/material.dart';
import 'student_attendance_screen.dart';
import 'student_assignments_screen.dart';

class StudentClassDetailsScreen extends StatelessWidget {
  final String className;

  const StudentClassDetailsScreen({
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
        child: Column(
          children: [
            /// VIEW ASSIGNMENTS
            _actionCard(
              context,
              icon: Icons.assignment,
              title: "View Assignments",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentAssignmentsScreen(
                      className: className,
                    ),
                  ),
                );
              },
            ),

            /// VIEW ATTENDANCE (UNCHANGED)
            _actionCard(
              context,
              icon: Icons.event_available,
              title: "View Attendance",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentAttendanceScreen(
                      className: className,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
