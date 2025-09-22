// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ButtonSignInToGoogle extends StatefulWidget {
//   const ButtonSignInToGoogle({super.key});

//   @override
//   State<ButtonSignInToGoogle> createState() => _ButtonSignInToGoogleState();
// }

// class _ButtonSignInToGoogleState extends State<ButtonSignInToGoogle> {
//   bool isLoading = false;

//   // ✅ создаём экземпляр GoogleSignIn один раз
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'profile'],
//   );

//   Future<void> _signInWithGoogle(BuildContext context) async {
//     setState(() => isLoading = true);
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         setState(() => isLoading = false);
//         return;
//       }

//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);

//       // ✅ сохраняем вход
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);

//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     } catch (e) {
//       debugPrint("Ошибка входа: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Ошибка входа через Google")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton(
//       style: OutlinedButton.styleFrom(
//         backgroundColor: Colors.white,
//         side: BorderSide(color: Colors.orange.shade200, width: 2),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       ),
//       onPressed: isLoading ? null : () => _signInWithGoogle(context),
//       child: isLoading
//           ? const SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(
//                   'assets/images/Group 49.png',
//                   width: 20,
//                   height: 20,
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Google',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
