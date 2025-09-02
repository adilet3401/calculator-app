import 'package:calculator/calculator_page.dart';
import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/profile_page.dart';
import 'package:calculator/pages/rastomozhka_page.dart';
import 'package:calculator/pages/tnved_code.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WebViewPlatform.instance = WebKitWebViewPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 2;

  final screens = const [
    RastamozhkaPage(),
    TnvedPage(),
    CalculatorPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final items = <Widget>[
      Icon(Icons.local_shipping, size: 30),
      Icon(Icons.search, size: 30),
      Icon(Icons.calculate, size: 30),
      Icon(Icons.history, size: 30),
      Icon(Icons.person, size: 30),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens, // Сохраняем все страницы в памяти
      ),
      bottomNavigationBar: CurvedNavigationBar(
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        backgroundColor: scaffoldBackgroundColor,
        color: Colors.orange,
        height: 70,
        items: items,
        index: index,
        onTap: (value) => setState(() {
          index = value;
        }),
      ),
    );
  }
}
