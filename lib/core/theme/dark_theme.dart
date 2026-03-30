import 'package:flutter/material.dart';

ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    ),
  );
}


// extensions: const [
//   AppSemanticColors(
//     income: Color(0xFF4ADE80),
//     expense: Color(0xFFF87171),
//   ),
// ],