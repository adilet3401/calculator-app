import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserEmailPasswordline extends StatelessWidget {
  const UserEmailPasswordline({
    super.key,
    required this.icon,
    required this.hinText,
    this.controller,
    this.errorText,
    this.onChanged,
    this.obscureText = false,
    this.inputFormatters,
  });

  final String hinText;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.all(15),
          child: Icon(icon, color: Colors.orange.shade300, size: 20),
        ),
        labelStyle: TextStyle(color: Colors.grey),
        prefixIconColor: Colors.grey,
        prefixIconConstraints: BoxConstraints(minWidth: 25, minHeight: 25),
        hintText: hinText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange.shade200, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        errorText: errorText,
      ),
    );
  }
}
