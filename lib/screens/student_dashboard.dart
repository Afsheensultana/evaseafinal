import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'student_class_details_screen.dart';
import '../config/api_endpoints.dart';
import '../utils/app_session.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState
    extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    fetchStudentClasses();
  }

  Future<void> fetchStudentClasses() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getStudentClasses),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken!}",
        },
      );

      if (response.statusCode == 200) {

        final decoded =
            jsonDecode(response.body);

        final body =
            jsonDecode(decoded["body"]);

        final List<dynamic> classList =
            body["classes"];

        setState(() {
          classes = classList
              .map<Map<String, dynamic>>((item) {
            return {
              "class_id":
                  item["class_id"] ?? "",
              "name":
                  item["class_name"] ?? "Unnamed",
              "code":
                  item["section"] ?? "N/A",
              "attendance":
                  item["attendance"] ?? 75,
            };
          }).toList();

          isLoading = false;
        });

      } else {
        setState(() => isLoading = false);
      }

    } catch (e) {
      setState(() => isLoading = false);
      print("Student Fetch Error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double overallAttendance = classes.isNotEmpty
        ? classes
                .map((c) => c["attendance"] as int)
                .reduce((a, b) => a + b) /
            classes.length
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),

      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAFAFB),
        foregroundColor: const Color(0xFF1A1D2B),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "Your Classes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D2B),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: classes.length,
                          itemBuilder:
                              (context, index) {

                            final cls =
                                classes[index];

                            final attendance =
                                cls["attendance"]
                                    as int;

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 18),
                              padding:
                                  const EdgeInsets.all(16),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                        18),
                                border: Border.all(
                                  color: const Color(
                                      0xFFE8E8EC),
                                ),
                                boxShadow:
                                    const [
                                  BoxShadow(
                                    color:
                                        Color.fromRGBO(
                                            30,
                                            42,
                                            74,
                                            0.05),
                                    blurRadius: 20,
                                    offset:
                                        Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                        18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentClassDetailsScreen(
                                      className: cls["name"]?.toString() ?? "",
                                      classId: cls["class_id"]?.toString() ?? "",
                                    ),

                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [

                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor:
                                              const Color(
                                                      0xFFB8829E)
                                                  .withOpacity(
                                                      0.15),
                                          child:
                                              const Icon(
                                            Icons.school,
                                            color: Color(
                                                0xFFB8829E),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                cls["name"]
                                                    as String,
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize:
                                                      16,
                                                ),
                                              ),
                                              Text(
                                                "Section: ${cls["code"]}",
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Color(0xFF5A6078),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "$attendance%",
                                          style:
                                              const TextStyle(
                                            color: Color(
                                                0xFFB8829E),
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 14),

                                    TweenAnimationBuilder<
                                        double>(
                                      tween: Tween(
                                          begin: 0,
                                          end: attendance /
                                              100),
                                      duration:
                                          const Duration(
                                              milliseconds:
                                                  800),
                                      builder:
                                          (context,
                                              value,
                                              _) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                          child:
                                              LinearProgressIndicator(
                                            value:
                                                value,
                                            minHeight:
                                                8,
                                            backgroundColor:
                                                const Color(
                                                        0xFFB8829E)
                                                    .withOpacity(
                                                        0.15),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    Color(
                                                        0xFFB8829E)),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFFB8829E),
                        Color(0xFF9C6B87),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color:
                            Color.fromRGBO(
                                184,
                                130,
                                158,
                                0.4),
                        blurRadius: 20,
                        offset:
                            Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(
                          width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Overall Attendance",
                              style:
                                  TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                fontSize:
                                    16,
                              ),
                            ),
                            const SizedBox(
                                height: 4),
                            Text(
                              "${overallAttendance.toStringAsFixed(0)}%",
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize:
                                    20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
