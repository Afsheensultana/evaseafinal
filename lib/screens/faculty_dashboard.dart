import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';
import 'faculty_class_screen.dart';
import 'create_class_screen.dart';
import '../utils/app_session.dart';
import '../config/api_endpoints.dart';

class FacultyDashboard extends StatefulWidget {
  final String token;

  const FacultyDashboard({
    super.key,
    required this.token,
  });

  @override
  State<FacultyDashboard> createState() =>
      _FacultyDashboardState();
}

class _FacultyDashboardState
    extends State<FacultyDashboard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<Map<String, String>> classes = [];
  bool isLoading = true;

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
    fetchFacultyClasses();
  }

  Future<void> fetchFacultyClasses() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getFacultyClasses),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken!}",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body);

        final Map<String, dynamic> body =
            jsonDecode(decoded["body"]);

        final List<dynamic> classList =
            body["classes"];

        setState(() {
          classes = classList
              .map<Map<String, String>>((item) {
            return {
              "classId": item["class_id"].toString(),
              "className": item["class_name"].toString(),
              "subject": item["subject"].toString(),
              "year": item["year"].toString(),
            };
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void deleteClass(int index) {
    final TextEditingController confirmController =
        TextEditingController();
    final className =
        classes[index]["className"] ?? "this class";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {

          bool isValid =
              confirmController.text == "CONFIRM";

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("Confirm Delete"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Type CONFIRM to delete $className"),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  onChanged: (_) {
                    setStateDialog(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Type CONFIRM",
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: isValid
                    ? () {
                        Navigator.pop(context);
                        setState(() {
                          classes.removeAt(index);
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                              content: Text("Class Deleted")),
                        );
                      }
                    : null,
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color:
                        isValid ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Faculty Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              AppSession.token = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// STAT CARDS
              Row(
                children: [
                  _statCard(
                    "Total Classes",
                    classes.length.toString(),
                    Icons.school_outlined,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1E88E5),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    "Subjects",
                    classes.length.toString(),
                    Icons.menu_book_outlined,
                    const Color(0xFFE0F2F1),
                    const Color(0xFF00897B),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "Your Classes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {

                          final classItem = classes[index];

                          final classId =
                              classItem["classId"] ?? "";
                          final className =
                              classItem["className"] ?? "Unnamed Class";
                          final subject =
                              classItem["subject"] ?? "No Subject";
                          final year =
                              classItem["year"] ?? "";

                          return _classCard(
                            context,
                            classId,
                            className,
                            subject,
                            year,
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xFF00897B),
        elevation: 0,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          "Create Class",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          final result =
              await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateClassScreen(
                token: widget.token,
              ),
            ),
          );

          if (result != null) {
            fetchFacultyClasses();
          }
        },
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      Color bgColor,
      Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color:
                const Color(0xFFE8EDF3),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: iconColor,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(
    BuildContext context,
    String classId,
    String className,
    String subject,
    String year,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              const Color(0xFFE8EDF3),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7F6),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.meeting_room_outlined,
            color: Color(0xFF5E35B1),
            size: 22,
          ),
        ),
        title: Text(
          className,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 4),
          child: Text(
            "$subject • $year",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
        trailing:
            PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "delete") {
              deleteClass(index);
            }
          },
          itemBuilder: (context) =>
              const [
            PopupMenuItem(
              value: "delete",
              child:
                  Text("Delete Class"),
            )
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FacultyClassScreen(
                className: className,
                classId: classId,
              ),
            ),
          );
        },
      ),
    );
  }
}
