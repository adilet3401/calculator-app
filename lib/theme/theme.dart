// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   bool _isDarkTheme = false;

//   bool get isDarkTheme => _isDarkTheme;

//   ThemeProvider() {
//     _loadTheme(); // Загружаем тему при инициализации
//   }

//   ThemeData get lightTheme => ThemeData(
//     brightness: Brightness.light,
//     primaryColor: Colors.blue,
//     appBarTheme: AppBarTheme(
//       backgroundColor: Color(0xff16423C),
//       foregroundColor: Colors.black, // Цвет текста AppBar
//     ),
//     bottomAppBarTheme: BottomAppBarThemeData(color: Color(0xff16423C)),
//     scaffoldBackgroundColor: Colors.white, // Цвет фона Scaffold
//     textTheme: TextTheme(
//       bodyLarge: TextStyle(color: Colors.black), // Цвет текста
//       bodyMedium: TextStyle(color: Colors.red), // Цвет текста
//       bodySmall: TextStyle(color: Colors.black), // Цвет текста
//     ),
//     drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
//     dividerTheme: DividerThemeData(color: Colors.grey.shade400),
//     // cardColor: Colors.grey[100], // Цвет карточек
//     cardTheme: CardThemeData(
//       color: Colors.white, // Цвет карточек
//       shadowColor: Colors.grey.shade300,
//       elevation: 4,
//     ),
//   );

//   ThemeData get darkTheme => ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: Colors.grey[900],
//     appBarTheme: AppBarTheme(
//       backgroundColor: Color(0xff191b1e),
//       foregroundColor: Colors.white, // Цвет текста AppBar
//     ),
//     bottomAppBarTheme: BottomAppBarThemeData(color: Color(0xff191b1e)),
//     scaffoldBackgroundColor: Color(0xff1f2023), // Цвет фона Scaffold
//     textTheme: TextTheme(
//       bodyLarge: TextStyle(color: Colors.grey.shade500), // Цвет текста
//       bodyMedium: TextStyle(color: Colors.orange.shade300), // Цвет текста
//       bodySmall: TextStyle(color: Colors.grey.shade300), // Цвет текста
//     ),
//     drawerTheme: DrawerThemeData(backgroundColor: Color(0xff1f2023)),
//     dividerTheme: DividerThemeData(color: Colors.grey.shade200),
//     cardTheme: CardThemeData(
//       color: Color(0xff191b1e), // Цвет карточеk
//       elevation: 4,
//     ),
//   );

//   void toggleTheme() {
//     _isDarkTheme = !_isDarkTheme;
//     _saveTheme(); // Сохраняем тему
//     notifyListeners();
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
//     notifyListeners();
//   }

//   Future<void> _saveTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkTheme', _isDarkTheme);
//   }
// }
