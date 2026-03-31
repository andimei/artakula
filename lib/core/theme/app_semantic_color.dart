import 'package:flutter/material.dart';

// @immutable
// class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
//   final Color income;
//   final Color expense;

//   const AppSemanticColors({
//     required this.income,
//     required this.expense,
//   });

//   @override
//   AppSemanticColors copyWith({
//     Color? income,
//     Color? expense,
//   }) {
//     return AppSemanticColors(
//       income: income ?? this.income,
//       expense: expense ?? this.expense,
//     );
//   }

//   @override
//   AppSemanticColors lerp(
//       ThemeExtension<AppSemanticColors>? other,
//       double t,
//   ) {
//     if (other is! AppSemanticColors) return this;

//     return AppSemanticColors(
//       income: Color.lerp(income, other.income, t)!,
//       expense: Color.lerp(expense, other.expense, t)!,
//     );
//   }
// }

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
        // expense = const Color(0xFFE57373),
        expense = const Color.fromARGB(255, 15, 14, 14),
        balance = const Color.fromARGB(255, 15, 14, 14);

  const AppSemanticColors.dark()
      : income = const Color(0xFF27AE60),
        // expense = const Color(0xFFEF5350),
        expense = const Color.fromARGB(255, 15, 14, 14),
        balance = const Color.fromARGB(255, 15, 14, 14);

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