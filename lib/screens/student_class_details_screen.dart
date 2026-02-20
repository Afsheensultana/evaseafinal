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
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        title: Text(className),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// 📚 VIEW ASSIGNMENTS
            _actionCard(
              context,
              icon: Icons.menu_book_rounded,
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

            /// 📊 VIEW ATTENDANCE
            _actionCard(
              context,
              icon: Icons.bar_chart_rounded,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor:
              const Color(0xFFB8829E).withOpacity(0.15),
          child: Icon(
            icon,
            size: 26,
            color: const Color(0xFFB8829E),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1A1D2B),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFB8829E),
        ),

        onTap: onTap,
      ),
    );
  }
}
