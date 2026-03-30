import 'package:artakula/core/theme/app_semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:artakula/core/theme/app_color.dart';

ThemeData lightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(textTheme: TextTheme(
    
  ),
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: colorScheme,

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

    extensions: const [
      AppSemanticColors(
        income: Color(0xFF2ECC71),
        expense: Color(0xFFE57373),
      ),
    ],
  );

  
}