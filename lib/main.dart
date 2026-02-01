import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EvalSeaApp());
}

class EvalSeaApp extends StatelessWidget {
  const EvalSeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
