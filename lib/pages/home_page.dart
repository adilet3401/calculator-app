import 'package:calculator/pages/calculator_page.dart';
import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/profile_page.dart';
import 'package:calculator/pages/rastomozhka_page.dart';
import 'package:calculator/pages/tnved_code.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

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

  // Цвета для фона активной иконки в навбаре (по страницам)
  final List<Color> iconBgColors = [
    Colors.black, // RastamozhkaPage
    Colors.white, // TnvedPage
    Colors.black, // CalculatorPage
    Colors.white, // HistoryPage
    Colors.white, // ProfilePage
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.local_shipping, size: 30, color: Colors.black),
      const Icon(Icons.search, size: 30, color: Colors.black),
      const Icon(Icons.calculate, size: 30, color: Colors.black),
      const Icon(Icons.history, size: 30, color: Colors.black),
      const Icon(Icons.person, size: 30, color: Colors.black),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens, // Сохраняем все страницы в памяти
      ),
      bottomNavigationBar: CurvedNavigationBar(
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: iconBgColors[index], // фон под навбар
        buttonBackgroundColor: Colors.orange, // фон активной иконки
        color: Colors.orange, // цвет панели
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
