import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../utils/app_session.dart';
import 'assignment_details_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  final String title;
  final bool isOngoing;
  final String classId;

  const AssignmentListScreen({
    super.key,
    required this.title,
    required this.isOngoing,
    required this.classId,
  });

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen>
    with SingleTickerProviderStateMixin {

  List<dynamic> assignments = [];
  bool isLoading = true;
  String? error;

  final String apiUrl =
      "https://c9n9q8bz5h.execute-api.ap-south-1.amazonaws.com/dev/user/get_assignment_faculty/get_assignment_faculty";

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

    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken}",
        },
        body: jsonEncode({
          "class_id": widget.classId,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final body = decoded["body"] is String
            ? jsonDecode(decoded["body"])
            : decoded["body"];

        setState(() {
          assignments = widget.isOngoing
              ? body["ongoing"] ?? []
              : body["previous"] ?? [];
          isLoading = false;
        });

        _controller.forward();
      } else {
        setState(() {
          error = "Server Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Something went wrong";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // softer background
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? _buildShimmer()
            : error != null
                ? Center(child: Text(error!))
                : assignments.isEmpty
                    ? const Center(
                        child: Text(
                          "No Assignments Found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          itemCount: assignments.length,
                          itemBuilder: (context, index) {
                            return _assignmentTile(
                                assignments[index],
                                index);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _assignmentTile(
      Map<String, dynamic> assignment,
      int index) {

    final topic =
        assignment["topic"] ?? "No Title";
    final deadline =
        assignment["deadline"] ?? "N/A";

    final assignmentId =
        assignment["assignment_id"] ??
        assignment["id"] ??
        "";

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFEDEFF5)), // light border
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.isOngoing
                  ? const Color(0xFFE6F4EA)
                  : const Color(0xFFE8F0FE),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              widget.isOngoing
                  ? Icons.schedule_rounded
                  : Icons.history_rounded,
              color: widget.isOngoing
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF1565C0),
            ),
          ),
          title: Text(
            topic,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding:
                const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  deadline,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () {
            if (assignmentId.isEmpty) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AssignmentDetailsScreen(
                  classId: widget.classId,
                  assignmentId:
                      assignmentId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFEAECEF),
          highlightColor:
              const Color(0xFFF5F6F8),
          child: Container(
            margin:
                const EdgeInsets.only(bottom: 14),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
