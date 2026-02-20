import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatelessWidget {
  final String className;

  const StudentAttendanceScreen({
    super.key,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    // STATIC DATA (LOGIC UNCHANGED)
    const int totalClasses = 40;
    const int attendedClasses = 34;
    const int attendancePercentage = 85;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: Text("$className Attendance"),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ATTENDANCE SUMMARY CARD
            Container(
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    children: const [
                      Icon(
                        Icons.percent,
                        color: Color(0xFFB8829E),
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Attendance Percentage",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D2B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PERCENTAGE VALUE
                  const Text(
                    "$attendancePercentage%",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8829E),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(
                    color: Color(0xFFE8E8EC),
                    thickness: 1,
                  ),

                  const SizedBox(height: 20),

                  /// TOTAL CLASSES
                  _infoRow(
                    icon: Icons.class_,
                    label: "Total Classes",
                    value: totalClasses.toString(),
                    color: const Color(0xFF5A6078),
                  ),

                  const SizedBox(height: 16),

                  /// ATTENDED CLASSES
                  _infoRow(
                    icon: Icons.check_circle,
                    label: "Classes Attended",
                    value: attendedClasses.toString(),
                    color: const Color(0xFFB8829E),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1D2B),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D2B),
          ),
        ),
      ],
    );
  }
}
