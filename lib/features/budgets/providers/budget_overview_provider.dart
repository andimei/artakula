import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/budgets/providers/budget_provider.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/providers/category_provider.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetWithSpending {
  final Budget budget;
  final Category? category;
  final int spent;
  final int remaining;

  BudgetWithSpending({
    required this.budget,
    required this.category,
    required this.spent,
    required this.remaining,
  });

  double get progress => budget.amount > 0
      ? (spent / budget.amount).clamp(0.0, 1.0)
      : 0.0;

  bool get isOverspent => spent > budget.amount;
}

final budgetOverviewProvider =
    Provider.family<List<BudgetWithSpending>, DateTime>((ref, month) {
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final categories = ref.watch(categoryProvider);

  final now = month;
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  return budgets.map((budget) {
    final category = categories.firstWhereOrNull(
      (c) => c.id == budget.categoryId,
    );

    final spent = transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.categoryId == budget.categoryId &&
            tx.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(monthEnd))
        .fold(0, (sum, tx) => sum + tx.amount);

    final remaining = budget.amount - spent;

    return BudgetWithSpending(
      budget: budget,
      category: category,
      spent: spent,
      remaining: remaining,
    );
  }).toList()
    ..sort((a, b) => (a.budget.order ?? 0).compareTo(b.budget.order ?? 0));
});
