import 'package:flutter/material.dart';
import 'create_assignment_screen.dart';
import 'assignment_list_screen.dart';

class FacultyClassScreen extends StatefulWidget {
  final String className;

  const FacultyClassScreen({
    super.key,
    required this.className,
  });

  @override
  State<FacultyClassScreen> createState() =>
      _FacultyClassScreenState();
}

class _FacultyClassScreenState
    extends State<FacultyClassScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

              /// ---------------- FOLDERS ----------------

              _folderTile(
                icon: Icons.folder_open,
                title: "Ongoing Assignments",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignmentListScreen(
                        title: "Ongoing Assignments",
                        isOngoing: true,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _folderTile(
                icon: Icons.folder,
                title: "Previous Assignments",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignmentListScreen(
                        title: "Previous Assignments",
                        isOngoing: false,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              /// ---------------- SIDE BY SIDE BUTTONS ----------------

              Row(
                children: [

                  /// CREATE ASSIGNMENT
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add_task,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Create Assignment",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFB8829E),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor:
                              const Color.fromRGBO(
                                  184, 130, 158, 0.4),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CreateAssignmentScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// START ATTENDANCE
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.how_to_reg,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Attendance",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF8A90A8),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          // TODO: Start Attendance API
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- FOLDER TILE ----------------

  Widget _folderTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFB8829E),
          child: Icon(
            icon,
            color: Colors.white,
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
          color: Color(0xFF8A90A8),
        ),
        onTap: onTap,
      ),
    );
  }
}
