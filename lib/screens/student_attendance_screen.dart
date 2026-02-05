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
      appBar: AppBar(
        title: Text("$className Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ATTENDANCE SUMMARY CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// Percentage
                    Row(
                      children: const [
                        Icon(
                          Icons.percent,
                          color: Colors.green,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Attendance Percentage",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "$attendancePercentage%",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const Divider(height: 32),

                    /// TOTAL CLASSES
                    _infoRow(
                      icon: Icons.class_,
                      label: "Total Classes",
                      value: totalClasses.toString(),
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    /// ATTENDED CLASSES
                    _infoRow(
                      icon: Icons.check_circle,
                      label: "Classes Attended",
                      value: attendedClasses.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
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
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
