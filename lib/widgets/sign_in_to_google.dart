import 'package:flutter/material.dart';

class ButtonSignInToGoogle extends StatefulWidget {
  const ButtonSignInToGoogle({super.key});

  @override
  State<ButtonSignInToGoogle> createState() => _ButtonSignInToGoogleState();
}

class _ButtonSignInToGoogleState extends State<ButtonSignInToGoogle> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange.shade200, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: () {}, //isLoading ? null : () => signInWithGoogle(context),
      child: isLoading
          ? CircularProgressIndicator()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/Group 49.png', width: 20, height: 20),
                SizedBox(width: 10),
                Text(
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
//