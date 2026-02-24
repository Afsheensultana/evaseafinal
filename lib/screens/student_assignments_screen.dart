import 'package:flutter/material.dart';
import 'student_assignment_folder_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String className;
  final String classId;

  const StudentAssignmentsScreen({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    print("RECEIVED CLASS ID IN ASSIGNMENTS SCREEN: ${widget.classId}");

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        title: Text(
          widget.className,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Assignments",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 24),

              _folderCard(
                title: "Ongoing Assignments",
                icon: Icons.schedule_rounded,
                type: "ongoing",
              ),

              _folderCard(
                title: "Previous Assignments",
                icon: Icons.history_rounded,
                type: "previous",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _folderCard({
    required String title,
    required IconData icon,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(30, 42, 74, 0.04),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: type == "ongoing"
                ? const Color(0xFFE8F2FF)
                : const Color(0xFFF1F3F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: type == "ongoing"
                ? const Color(0xFF3B82F6)
                : const Color(0xFF6B7280),
            size: 22,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),

        onTap: () {

          print("SENDING CLASS ID TO FOLDER: ${widget.classId}");
          print("TYPE SELECTED: $type");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentAssignmentFolderScreen(
                title: title,
                type: type,
                classId: widget.classId,
              ),
            ),
          );
        },
      ),
    );
  }
}
