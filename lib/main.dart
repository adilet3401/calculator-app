import 'package:calculator/pages/download_page.dart';
import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/home_page.dart';
// import 'package:calculator/sign-log_in%20pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Проверка Firestore
  try {
    await FirebaseFirestore.instance.collection('test').add({'check': true});
    // ignore: avoid_print
    print('Firestore работает!');
  } catch (e) {
    // ignore: avoid_print
    print('Ошибка Firestore: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DownloadPage(), // Исправлено: передаем только виджет
      routes: {
        '/home': (context) => HomePage(),
        '/history': (context) => HistoryPage(),
      },
    );
  }
}
