import 'package:flutter/material.dart';
import '../../data/models/expense.dart';
import '../widgets/expense_form.dart';

class ExpenseFormPage extends StatelessWidget {
  final Expense? expense;

  const ExpenseFormPage({super.key, this.expense});

  bool get isEdit => expense != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
      ),
      body: ExpenseForm(expense: expense),
    );
  }
}
