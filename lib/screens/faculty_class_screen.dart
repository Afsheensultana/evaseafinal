import 'package:flutter/material.dart';
import 'create_assignment_screen.dart';
import 'assignment_list_screen.dart';

class FacultyClassScreen extends StatefulWidget {
  final String className;
  final String classId;

  const FacultyClassScreen({
    super.key,
    required this.className,
    required this.classId,
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
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // softer background

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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// ---------------- FOLDERS ----------------

              _folderTile(
                icon: Icons.schedule_rounded,
                title: "Ongoing Assignments",
                iconBg: const Color(0xFFE6F4EA),
                iconColor: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssignmentListScreen(
                        title: "Ongoing Assignments",
                        isOngoing: true,
                        classId: widget.classId,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _folderTile(
                icon: Icons.history_rounded,
                title: "Previous Assignments",
                iconBg: const Color(0xFFE8F0FE),
                iconColor: const Color(0xFF1565C0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssignmentListScreen(
                        title: "Previous Assignments",
                        isOngoing: false,
                        classId: widget.classId,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              /// ---------------- ACTION BUTTONS ----------------

              Row(
                children: [

                  /// CREATE ASSIGNMENT
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add_task_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          "Create Assignment",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFB8829E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
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

                  /// ATTENDANCE
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.how_to_reg_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          "Attendance",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFEDEFF5),
                          foregroundColor:
                              const Color(0xFF4A5568),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
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

  /// ---------------- LIGHT MINIMAL FOLDER TILE ----------------

  Widget _folderTile({
    required IconData icon,
    required String title,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEDEFF5),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1A1D2B),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
