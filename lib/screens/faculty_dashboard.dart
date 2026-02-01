import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'faculty_class_screen.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _classCard(context, "Class 1", "Python", "2nd Year"),
          _classCard(context, "Class 2", "DBMS", "3rd Year"),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: CREATE CLASS API
        },
        icon: const Icon(Icons.add),
        label: const Text("Create Class"),
      ),
    );
  }

  Widget _classCard(
      BuildContext context, String className, String subject, String year) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        title: Text(
          className,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$subject • $year"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FacultyClassScreen(className: className),
            ),
          );
        },
      ),
    );
  }
}