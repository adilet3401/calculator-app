import 'package:calculator/pages/download_page.dart';
import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Инициализация локали
  await initializeDateFormatting('ru', null);

  // Проверка и выполнение авторизации
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  // Проверка Firestore (только чтение, если запись запрещена)
  try {
    await FirebaseFirestore.instance.collection('test').doc('check').get();
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
