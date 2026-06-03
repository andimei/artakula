import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/providers/category_provider.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------- Time Range Filter ----------

enum TimeRangeType { today, last7Days, month, dateRange }

class TimeRangeFilter {
  final TimeRangeType type;
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;

  const TimeRangeFilter({
    this.type = TimeRangeType.last7Days,
    this.selectedDate,
    this.startDate,
    this.endDate,
  });

  TimeRangeFilter copyWith({
    TimeRangeType? type,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TimeRangeFilter(
      type: type ?? this.type,
      selectedDate: selectedDate ?? this.selectedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool contains(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (type) {
      case TimeRangeType.today:
        return today == d;
      case TimeRangeType.last7Days:
        final start = today.subtract(const Duration(days: 6));
        return d.compareTo(start) >= 0 && d.compareTo(today) <= 0;
      case TimeRangeType.month:
        final sel = selectedDate ?? now;
        return date.year == sel.year && date.month == sel.month;
      case TimeRangeType.dateRange:
        if (startDate == null || endDate == null) return false;
        final s = DateTime(startDate!.year, startDate!.month, startDate!.day);
        final e = DateTime(endDate!.year, endDate!.month, endDate!.day);
        return d.compareTo(s) >= 0 && d.compareTo(e) <= 0;
    }
  }
}

final timeRangeFilterProvider = StateProvider<TimeRangeFilter>((ref) {
  return const TimeRangeFilter();
});

// ---------- Category Summary ----------

class CategorySummary {
  final Category category;
  final int totalIncome;
  final int totalExpense;

  const CategorySummary({
    required this.category,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  int get total => totalIncome + totalExpense;
}

final categorySummaryProvider = Provider<List<CategorySummary>>((ref) {
  final filter = ref.watch(timeRangeFilterProvider);
  final transactions = ref.watch(transactionProvider);
  final categories = ref.watch(categoryProvider);

  final categoryMap = {for (final c in categories) c.id: c};

  final incomeMap = <String, int>{};
  final expenseMap = <String, int>{};
  const uncategorizedKey = '__uncategorized__';

  for (final tx in transactions) {
    if (!filter.contains(tx.date)) continue;
    if (tx.type == TransactionType.transfer) continue;

    final key = (tx.categoryId != null && categoryMap.containsKey(tx.categoryId))
        ? tx.categoryId!
        : uncategorizedKey;

    switch (tx.type) {
      case TransactionType.income:
        incomeMap[key] = (incomeMap[key] ?? 0) + tx.amount;
      case TransactionType.expense:
        expenseMap[key] = (expenseMap[key] ?? 0) + tx.amount;
      case TransactionType.transfer:
        break;
    }
  }

  final allIds = {...incomeMap.keys, ...expenseMap.keys};
  final result = allIds.where((id) => id != uncategorizedKey).map((id) {
    return CategorySummary(
      category: categoryMap[id]!,
      totalIncome: incomeMap[id] ?? 0,
      totalExpense: expenseMap[id] ?? 0,
    );
  }).toList();

  // Add uncategorized if present
  if (incomeMap.containsKey(uncategorizedKey) ||
      expenseMap.containsKey(uncategorizedKey)) {
    result.add(CategorySummary(
      category: Category(
        id: uncategorizedKey,
        name: 'Uncategorized',
        isIncome: false,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
      ),
      totalIncome: incomeMap[uncategorizedKey] ?? 0,
      totalExpense: expenseMap[uncategorizedKey] ?? 0,
    ));
  }

  result.sort((a, b) => b.total.compareTo(a.total));
  return result;
});
