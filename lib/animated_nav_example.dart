import 'package:flutter/material.dart';

class AnimatedNavExample extends StatefulWidget {
  const AnimatedNavExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedNavExampleState createState() => _AnimatedNavExampleState();
}

class _AnimatedNavExampleState extends State<AnimatedNavExample> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _pressedIndex = -1; // индекс кнопки, которая нажата

  final List<Widget> _pages = [
    Center(child: Text("Калькулятор", style: TextStyle(fontSize: 28))),
    Center(child: Text("Растаможка", style: TextStyle(fontSize: 28))),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavButton("Калькулятор", 0),
            SizedBox(width: 12),
            _buildNavButton("Растаможка", 1),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _pages,
      ),
    );
  }

  Widget _buildNavButton(String text, int index) {
    final bool isActive = _currentIndex == index;
    final bool isPressed = _pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressedIndex = index); // при нажатии уменьшаем
      },
      onTapUp: (_) {
        setState(() => _pressedIndex = -1); // отпустили
      },
      onTapCancel: () {
        setState(() => _pressedIndex = -1); // отмена
      },
      onTap: () => _onNavTap(index),
      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0, // эффект нажатия
        duration: Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
