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
  final List<Category> categories;
  final int spent;
  final int remaining;

  BudgetWithSpending({
    required this.budget,
    required this.categories,
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
  final allCategories = ref.watch(categoryProvider);

  final now = month;
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 1);

  return budgets.map((budget) {
    final matchedCategories = budget.categoryIds.isEmpty
        ? <Category>[]
        : budget.categoryIds
            .map((id) => allCategories.firstWhereOrNull((c) => c.id == id))
            .nonNulls
            .toList();

    final spent = transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            budget.categoryIds.contains(tx.categoryId) &&
            tx.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(monthEnd))
        .fold(0, (sum, tx) => sum + tx.amount);

    final remaining = budget.amount - spent;

    return BudgetWithSpending(
      budget: budget,
      categories: matchedCategories,
      spent: spent,
      remaining: remaining,
    );
  }).toList()
    ..sort((a, b) => (a.budget.order ?? 0).compareTo(b.budget.order ?? 0));
});
