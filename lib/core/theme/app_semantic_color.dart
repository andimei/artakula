import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color income;
  final Color expense;
  final Color balance;

  const AppSemanticColors({
    required this.income,
    required this.expense,
    required this.balance,
  });

  const AppSemanticColors.light()
      : income = const Color(0xFF2ECC71),
        expense = const Color(0xFFE57373),
        balance = const Color(0xFF313131);

  const AppSemanticColors.dark()
      : income = const Color(0xFF4ADE80),
        expense = const Color(0xFFF87171),
        balance = Colors.white;

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? expense,
    Color? balance,
  }) {
    return AppSemanticColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      balance: balance ?? this.balance,
    );
  }

  @override
  AppSemanticColors lerp(
      ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;

    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      balance: Color.lerp(balance, other.balance, t)!,
    );
  }
}