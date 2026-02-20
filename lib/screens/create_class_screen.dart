import 'dart:convert';
import 'package:evaseafinal/utils/app_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CreateClassScreen extends StatefulWidget {
  final String token;

  const CreateClassScreen({super.key, required this.token});

  @override
  State<CreateClassScreen> createState() =>
      _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController classNameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController capacityController =
      TextEditingController(text: "100");

  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  // ================= YEAR POPUP =================
  void _showYearSelector() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            "Select Year",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["1", "2", "3", "4"].map((year) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  yearController.text = year;
                });
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFB8829E),
                child: Text(
                  year,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= SEMESTER POPUP =================
  void _showSemesterSelector() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            "Select Semester",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ["1", "2"].map((sem) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    semesterController.text = sem;
                  });
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFB8829E),
                  child: Text(
                    sem,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= CREATE CLASS =================
  Future<void> createClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    const String apiUrl =
        "https://c9n9q8bz5h.execute-api.ap-south-1.amazonaws.com/dev/user/create_class/create_class";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSession.idToken!}",
        },
        body: jsonEncode({
          "class_name": classNameController.text.trim(),
          "year": yearController.text.trim(),
          "semester": semesterController.text.trim(),
          "subject": subjectController.text.trim(),
          "section": sectionController.text.trim(),
          "max_capacity": capacityController.text.trim(),
        }),
      );

      final outerData = jsonDecode(response.body);
      final innerData = outerData["body"] != null
          ? jsonDecode(outerData["body"])
          : outerData;

      if (outerData["statusCode"] == 200) {
        if (!mounted) return;

        final String joinLink = innerData["join_link"] ?? "";

        // 🔥 SHORT DISPLAY VERSION (UI Only)
        String shortLink = joinLink.length > 60
            ? "${joinLink.substring(0, 40)}...${joinLink.substring(joinLink.length - 10)}"
            : joinLink;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Class Created 🎉"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Share this link with students:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // ✅ Shortened display only
                SelectableText(
                  shortLink,
                  style: const TextStyle(
                    color: Color(0xFFB8829E),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8829E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: const Text(
                      "Copy Link",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      // ✅ FULL LINK COPIED
                      await Clipboard.setData(
                        ClipboardData(text: joinLink),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Link copied to clipboard"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              )
            ],
          ),
        );

        _clearFields();
      } else {
        _showError(innerData["error"] ?? "Something went wrong");
      }
    } catch (e) {
      _showError("Network error: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _clearFields() {
    classNameController.clear();
    yearController.clear();
    semesterController.clear();
    subjectController.clear();
    sectionController.clear();
    capacityController.text = "100";
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            const Color.fromARGB(255, 233, 191, 188),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    classNameController.dispose();
    yearController.dispose();
    semesterController.dispose();
    subjectController.dispose();
    sectionController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: AppBar(
        title: const Text("Create Class"),
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
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE8E8EC),
                ),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildField(classNameController, "Class Name", Icons.meeting_room),
                    _buildField(subjectController, "Subject", Icons.menu_book),
                    _buildField(
                        yearController,
                        "Year",
                        Icons.calendar_month,
                        readOnly: true,
                        onTap: _showYearSelector),
                    _buildField(
                        semesterController,
                        "Semester",
                        Icons.layers,
                        readOnly: true,
                        onTap: _showSemesterSelector),
                    _buildField(sectionController, "Section", Icons.badge),
                    _buildField(capacityController, "Max Capacity",
                        Icons.people,
                        isNumber: true),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : createClass,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8829E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Create Class",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty)
            return "Enter $label";
          if (isNumber && int.tryParse(value) == null) {
            return "Enter valid number";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFB8829E),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
