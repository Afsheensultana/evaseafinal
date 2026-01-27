import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? obscure : false,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => obscure = !obscure);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
