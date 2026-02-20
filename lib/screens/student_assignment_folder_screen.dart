import 'package:flutter/material.dart';

class StudentAssignmentFolderScreen extends StatefulWidget {
  final String title;
  final bool isOngoing; // ✅ Added flag

  const StudentAssignmentFolderScreen({
    super.key,
    required this.title,
    required this.isOngoing,
  });

  @override
  State<StudentAssignmentFolderScreen> createState() =>
      _StudentAssignmentFolderScreenState();
}

class _StudentAssignmentFolderScreenState
    extends State<StudentAssignmentFolderScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> assignments = [
    "Assignment 1",
    "Assignment 2",
    "Assignment A",
    "Assignment B",
  ];

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
        title: Text(widget.title),
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {

              final assignment = assignments[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  /// 📄 Assignment Icon
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFFB8829E).withOpacity(0.15),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFFB8829E),
                    ),
                  ),

                  /// 📝 Title
                  title: Text(
                    assignment,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1D2B),
                    ),
                  ),

                  /// 🔥 Trailing Area
                  trailing: widget.isOngoing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            /// ⬆ Upload Button
                            IconButton(
                              icon: const Icon(
                                Icons.cloud_upload,
                                color: Color(0xFFB8829E),
                              ),
                              onPressed: () {
                                // 🔒 Upload logic here
                              },
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Color(0xFFB8829E),
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFFB8829E),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
