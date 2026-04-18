import 'package:flutter/material.dart';
import 'app_drawer.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          "Welcome to Parent Panel",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
