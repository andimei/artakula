import 'package:flutter/material.dart';

// ThemeData darkTheme() {
//   return ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: Colors.blue,
//       brightness: Brightness.dark,
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//     ),
//   );
// }


// extensions: const [
//   AppSemanticColors(
//     income: Color(0xFF4ADE80),
//     expense: Color(0xFFF87171),
//   ),
// ],

import 'package:artakula/core/theme/app_semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:artakula/core/theme/app_color.dart';

// ThemeData lightTheme() {
//   final colorScheme = ColorScheme.fromSeed(
//     seedColor: AppColors.primary,
//     brightness: Brightness.light,
//   );

//   return ThemeData(textTheme: TextTheme(
    
//   ),
//     useMaterial3: true,
//     brightness: Brightness.light,

//     colorScheme: colorScheme,

//     // Background
//     scaffoldBackgroundColor: AppColors.background,
//     canvasColor: AppColors.background,

//     // AppBar
//     appBarTheme: AppBarTheme(
//       elevation: 0,
//       centerTitle: false,
//       backgroundColor: AppColors.background,
//       surfaceTintColor: Colors.transparent,
//       foregroundColor: colorScheme.onSurface,
//     ),

//     // FAB
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//       backgroundColor: colorScheme.primary,
//       foregroundColor: colorScheme.onPrimary,
//     ),

//     // Bottom Navigation
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       selectedItemColor: colorScheme.primary,
//       unselectedItemColor: Colors.grey,
//       backgroundColor: AppColors.surface,
//       elevation: 0,
//     ),

//     // Divider
//     dividerTheme: const DividerThemeData(
//       thickness: 1,
//       color: AppColors.border,
//     ),

//     extensions: const [
//       AppSemanticColors(
//         income: Color(0xFF2ECC71),
//         expense: Color(0xFFE57373),
//       ),
//     ],
//   );

  
// }

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,

    textTheme: const TextTheme(),

    // Background
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,

    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.surface,
      elevation: 0,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      thickness: 1,
      color: AppColors.border,
    ),

    // THEME EXTENSION
    extensions: const [
      AppSemanticColors.dark(),
    ],
  );
}