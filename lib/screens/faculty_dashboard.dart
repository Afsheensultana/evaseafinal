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
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    fetchFacultyClasses();
  }

  // ✅ API CALL
 Future<void> fetchFacultyClasses() async {
  try {
    final response = await http.get(
      Uri.parse(ApiEndpoints.getFacultyClasses),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AppSession.idToken!}",
      },
    );

    print("RAW RESPONSE: ${response.body}");

    if (response.statusCode == 200) {

      // First decode
      final Map<String, dynamic> decoded =
          jsonDecode(response.body);

      // Second decode (important)
      final Map<String, dynamic> body =
          jsonDecode(decoded["body"]);

      final List<dynamic> classList =
          body["classes"];

      print("CLASS LIST: $classList");

      setState(() {
        classes = classList
            .map<Map<String, String>>((item) {
          return {
            "classId": 
                item["class_id"].toString(),
            "className":
                item["class_name"].toString(),
            "subject":
                item["subject"].toString(),
            "year":
                item["year"].toString(),
          };
        }).toList();

        isLoading = false;
      });

    } else {
      setState(() => isLoading = false);
    }

  } catch (e) {
    setState(() => isLoading = false);
    print("ERROR: $e");
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
              borderRadius:
                  BorderRadius.circular(16),
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
                          BorderRadius.circular(12),
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
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Faculty Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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

              Row(
                children: [
                  _statCard(
                    "Total Classes",
                    classes.length.toString(),
                    Icons.school,
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    "Subjects",
                    classes.length.toString(),
                    Icons.menu_book,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Your Classes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {

                        final classItem = classes[index];

                        final classId = classItem["classId"] ?? "";
                        final className = classItem["className"] ?? "Unnamed Class";
                        final subject = classItem["subject"] ?? "No Subject";
                        final year = classItem["year"] ?? "";

                        return _classCard(
                          context,
                          classId,   // ✅ pass classId
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
            const Color(0xFFB8829E),
        icon: const Icon(
          Icons.add_circle_outline,
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
      IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                const Color(0xFFE8E8EC),
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:
                    const Color(0xFFB8829E)),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFFB8829E),
              ),
            ),
            Text(title),
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
          const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFE8E8EC),
        ),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor:
              Color(0xFFB8829E),
          child: Icon(
            Icons.meeting_room,
            color: Colors.white,
          ),
        ),
        title: Text(
          className,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.menu_book,
              size: 16,
              color: Color(0xFF5A6078),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "$subject • $year",
                style: const TextStyle(
                  color:
                      Color(0xFF5A6078),
                ),
              ),
            ),
          ],
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
        classId: classId,   // ✅ ADD THIS
      ),
    ),
  );
},

      ),
    );
  }
}
