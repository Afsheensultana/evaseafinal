import 'package:flutter/material.dart';
import 'student_assignment_folder_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String className;

  const StudentAssignmentsScreen({
    super.key,
    required this.className,
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// 📂 ONGOING FOLDER
              _folderCard(
                title: "Ongoing Assignments",
                icon: Icons.folder_open_rounded,
                isOngoing: true,
              ),

              /// 📁 PREVIOUS FOLDER
              _folderCard(
                title: "Previous Assignments",
                icon: Icons.folder_rounded,
                isOngoing: false,
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
    required bool isOngoing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8EC)),
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor:
              const Color(0xFFB8829E).withOpacity(0.15),
          child: Icon(
            icon,
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

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentAssignmentFolderScreen(
                title: title,        // ✅ Correct parameter
                isOngoing: isOngoing,
              ),
            ),
          );
        },
      ),
    );
  }
}
