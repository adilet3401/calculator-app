import 'package:calculator/pages/calculator_page.dart';
import 'package:calculator/pages/history_page.dart';
import 'package:calculator/pages/profile_page.dart';
import 'package:calculator/pages/rastomozhka_page.dart';
import 'package:calculator/pages/tnved_code.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // для блюра

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
    final items = [
      Icons.local_shipping,
      Icons.search,
      Icons.calculate,
      Icons.history,
      Icons.person,
    ];

    return Scaffold(
      extendBody: true, // 🔥 чтобы фон продолжался под навбар
      backgroundColor: Colors.black, // общий фон
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 🔥 размытие
          child: BottomNavigationBar(
            selectedFontSize: 1,
            currentIndex: index,
            onTap: (value) => setState(() => index = value),
            // ignore: deprecated_member_use
            backgroundColor: Colors.white.withOpacity(
              0.1,
            ), // 👈 светлый и прозрачный фон
            elevation: 0, // убираем тень
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orangeAccent,
            unselectedItemColor: Colors.grey[600],
            showUnselectedLabels: false,
            items: List.generate(items.length, (i) {
              final isActive = i == index;
              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Colors.deepOrange, Colors.orangeAccent],
                          )
                        : null,
                  ),
                  child: Icon(
                    items[i],
                    size: isActive ? 28 : 24,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
                label: '',
              );
            }),
          ),
        ),
      ),
    );
  }
}
