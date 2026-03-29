import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../../categories/providers/category_provider.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  // String _fromAccount = 'cash';
  // String? _toAccount;

  String? _categoryId;
  String? _fromAccountId;
  String? _toAccountId;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final tx = widget.transaction;
    _categoryId = tx?.categoryId;

    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _noteController.text = tx.note;
      _type = tx.type;
      _fromAccountId = tx.fromAccountId;
      _toAccountId = tx.toAccountId;
      _selectedDate = tx.date; // ambil dari data lama
    } else {
      _selectedDate = DateTime.now(); // default hari ini
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        // biar gak overflow
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TYPE
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _type = val!;
                  _categoryId = null; // reset biar gak mismatch
                });
              },
              decoration: const InputDecoration(labelText: 'Type'),
            ),

            /// CATEGORY
            if (_type != TransactionType.transfer)
              Consumer(
                builder: (context, ref, _) {
                  final categories = ref.watch(
                    categoriesByTypeProvider(_type == TransactionType.income),
                  );
                  final validCategory =
                      categories.any(
                        (c) => c.id == _categoryId,
                      )
                      ? _categoryId
                      : null;

                  return DropdownButtonFormField<String>(
                    // initialValue: _categoryId,
                    initialValue: validCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _categoryId = val),
                    decoration: const InputDecoration(labelText: 'Category'),
                  );
                },
              ),

            const SizedBox(height: 12),

            /// DATE PICKER
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(_selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// AMOUNT
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            const SizedBox(height: 12),

            /// FROM ACCOUNT
            Consumer(
              builder: (context, ref, _) {
                final accounts = ref.watch(accountProvider);

                final validAccount = accounts.any((a) => a.id == _fromAccountId)
                    ? _fromAccountId
                    : null;

                return DropdownButtonFormField<String>(
                  initialValue: validAccount,
                  decoration: const InputDecoration(
                    labelText: 'From Account',
                  ),
                  items: accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(acc.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _fromAccountId = val),
                );
              },
            ),

            const SizedBox(height: 12),

            /// TO ACCOUNT (TRANSFER ONLY)
            if (_type == TransactionType.transfer)
              Consumer(
                builder: (context, ref, _) {
                  final accounts = ref.watch(accountProvider);

                  final validAccount = accounts.any((a) => a.id == _toAccountId)
                      ? _toAccountId
                      : null;

                  return DropdownButtonFormField<String>(
                    initialValue: validAccount,
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                    ),
                    items: accounts.map((acc) {
                      return DropdownMenuItem(
                        value: acc.id,
                        child: Text(acc.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _toAccountId = val),
                  );
                },
              ),

            const SizedBox(height: 12),

            /// NOTE
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),

            const SizedBox(height: 20),

            /// SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PICK DATE
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (_fromAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select account')),
      );
      return;
    }

    if (_type != TransactionType.transfer && _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select category')),
      );
      return;
    }

    final notifier = ref.read(transactionProvider.notifier);

    if (widget.transaction == null) {
      // ===== ADD =====
      final tx = Transaction(
        id: const Uuid().v4(),
        type: _type,
        amount: amount,
        date: _selectedDate,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        fromAccountId: _fromAccountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        note: _noteController.text,
      );

      notifier.add(tx);
    } else {
      // ===== UPDATE =====
      final tx = widget.transaction!;

      tx.type = _type;
      tx.amount = amount;
      tx.date = _selectedDate;
      tx.categoryId = _type == TransactionType.transfer ? null : _categoryId;
      tx.fromAccountId = _fromAccountId!;
      tx.toAccountId = _type == TransactionType.transfer ? _toAccountId : null;
      tx.note = _noteController.text;

      notifier.update(tx);
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
