import 'package:artakula/core/theme/app_semantic_color.dart';
import 'package:flutter/material.dart';

extension AppThemeExt on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
