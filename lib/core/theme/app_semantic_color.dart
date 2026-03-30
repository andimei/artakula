import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color income;
  final Color expense;

  const AppSemanticColors({
    required this.income,
    required this.expense,
  });

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? expense,
  }) {
    return AppSemanticColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  AppSemanticColors lerp(
      ThemeExtension<AppSemanticColors>? other,
      double t,
  ) {
    if (other is! AppSemanticColors) return this;

    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }
}