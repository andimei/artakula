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
  String _fromAccount = 'cash';
  String? _toAccount;
  String? _categoryId;

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
      _fromAccount = tx.fromAccountId;
      _toAccount = tx.toAccountId;
      _selectedDate = tx.date; // 🔥 ambil dari data lama
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

                  return DropdownButtonFormField<String>(
                    initialValue: _categoryId,
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

            /// DATE PICKER 🔥
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
            TextField(
              decoration: const InputDecoration(labelText: 'From Account'),
              onChanged: (val) => _fromAccount = val,
            ),

            const SizedBox(height: 12),

            /// TO ACCOUNT (TRANSFER ONLY)
            if (_type == TransactionType.transfer)
              TextField(
                decoration: const InputDecoration(labelText: 'To Account'),
                onChanged: (val) => _toAccount = val,
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

  /// 📅 PICK DATE
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

    final tx = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount: amount,
      type: _type,
      date: _selectedDate, // 🔥 pakai tanggal yang dipilih
      fromAccountId: _fromAccount,
      toAccountId: _type == TransactionType.transfer ? _toAccount : null,
      note: _noteController.text,
      categoryId: _type == TransactionType.transfer ? null : _categoryId,
    );

    final notifier = ref.read(transactionProvider.notifier);

    if (widget.transaction == null) {
      notifier.add(tx);
    } else {
      notifier.update(tx);
    }

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
