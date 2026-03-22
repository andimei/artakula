import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/expense_hive_service.dart';
import '../data/models/expense.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _load();
  }

  final ExpenseHiveService _service = ExpenseHiveService();

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(Expense expense) async {
    await _service.add(expense);
    _load();
  }

  Future<void> update(Expense expense) async {
    await _service.update(expense);
    _load();
  }

  Future<void> delete(Expense expense) async {
    await _service.delete(expense);
    _load();
  }

  Future<void> deleteWithUndo(
    BuildContext context,
    Expense expense,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    final backup = expense;
    final backupIndex = expense.key as int;

    await _service.delete(expense);
    _load();

    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await _service.putAt(backupIndex, backup);
            _load();
          },
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), controller.close);
  }
}
