import 'package:flutter/material.dart';

class ButtonSignInToGoogle extends StatefulWidget {
  const ButtonSignInToGoogle({super.key});

  @override
  State<ButtonSignInToGoogle> createState() => _ButtonSignInToGoogleState();
}

class _ButtonSignInToGoogleState extends State<ButtonSignInToGoogle> {
  bool isLoading = false;

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange.shade200, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: isLoading ? null : () => _signInWithGoogle(context),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/Group 49.png', width: 20, height: 20),
                const SizedBox(width: 10),
                const Text(
                  'Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
    );
  }
}
