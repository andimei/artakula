import 'package:artakula/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:artakula/features/expenses/presentation/widgets/expense_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/expense_provider.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.startToEnd,
          background: _deleteBackground(),
          onDismissed: (_) {
            ref.read(expenseProvider.notifier).deleteWithUndo(context, expense);
          },
          child: ExpenseTile(
            expense: expense,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExpenseFormPage(expense: expense),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
