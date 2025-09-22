import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/home_page.dart';
import 'package:calculator/sign-log_in%20pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('ru', null);

  // Проверка Firestore (только чтение, если запись запрещена)
  try {
    await FirebaseFirestore.instance.collection('test').doc('check').get();
    // ignore: avoid_print
    print('Firestore работает!');
  } catch (e) {
    // ignore: avoid_print
    print('Ошибка Firestore: $e');
  }

  // Проверка сохраненного входа
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const SignInPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
