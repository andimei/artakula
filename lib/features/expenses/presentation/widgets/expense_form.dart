import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/expense.dart';
import '../../controller/expense_provider.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense; // null = add, ada = edit

  const ExpenseForm({super.key, this.expense});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late String _selectedAccount;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );

    _noteController = TextEditingController(
      text: widget.expense?.note ?? '',
    );

    _selectedCategory = widget.expense?.category ?? 'Food';
    _selectedAccount = widget.expense?.account ?? 'Cash';
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedAccount,
            items: [
              'Cash',
              'BRI',
              'BNI',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedAccount = v!),
            decoration: const InputDecoration(labelText: 'Account'),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: [
              'Food',
              'Transport',
              'Shopping',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text(_formatDate(_selectedDate)),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: _saveExpense,
            child: Text(isEdit ? 'Update Expense' : 'Save Expense'),
          ),
        ],
      ),
    );
  }

  void _saveExpense() {
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(raw) ?? 0;

    if (widget.expense == null) {
      ref
          .read(expenseProvider.notifier)
          .add(
            Expense(
              id: const Uuid().v4(),
              name: "test",
              amount: amount,
              account: _selectedAccount,
              category: _selectedCategory,
              note: _noteController.text,
              date: _selectedDate,
            ),
          );
    } else {
      final expense = widget.expense!
        ..amount = amount
        ..account = _selectedAccount
        ..category = _selectedCategory
        ..note = _noteController.text
        ..date = _selectedDate;
      ref.read(expenseProvider.notifier).update(expense);
    }

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    return isToday ? 'Today' : DateFormat('dd/MM/yyyy').format(date);
  }
}
