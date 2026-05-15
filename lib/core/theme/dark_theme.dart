import 'package:artakula/core/theme/app_semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:artakula/core/theme/app_color.dart';

ThemeData darkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,

    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: Colors.grey,
      backgroundColor: colorScheme.surface,
      elevation: 0,
    ),

    dividerTheme: DividerThemeData(
      thickness: 1,
      color: colorScheme.outlineVariant,
    ),

    extensions: const [
      AppSemanticColors.dark(),
    ],
  );
}