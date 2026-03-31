import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/transactions/presentation/widgets/fintech_field.dart';
import 'package:artakula/features/transactions/presentation/widgets/keypad_button.dart';
import 'package:artakula/features/transactions/presentation/widgets/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../../categories/providers/category_provider.dart';

import 'package:auto_size_text/auto_size_text.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  // final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;

  int _amount = 0;
  late TextEditingController _amountController;

  String get formattedAmount {
    if (_amount == 0) return "0";

    return _amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }
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

  // @override
  // Widget build(BuildContext context) {
  //   final isEdit = widget.transaction != null;

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
  //     ),
  //     body: SingleChildScrollView(
  //       // biar gak overflow
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           /// TYPE
  //           DropdownButtonFormField<TransactionType>(
  //             initialValue: _type,
  //             items: TransactionType.values.map((type) {
  //               return DropdownMenuItem(
  //                 value: type,
  //                 child: Text(type.name),
  //               );
  //             }).toList(),
  //             onChanged: (val) {
  //               setState(() {
  //                 _type = val!;
  //                 _categoryId = null; // reset biar gak mismatch
  //               });
  //             },
  //             decoration: const InputDecoration(labelText: 'Type'),
  //           ),

  //           /// CATEGORY
  //           if (_type != TransactionType.transfer)
  //             Consumer(
  //               builder: (context, ref, _) {
  //                 final categories = ref.watch(
  //                   categoriesByTypeProvider(_type == TransactionType.income),
  //                 );
  //                 final validCategory =
  //                     categories.any(
  //                       (c) => c.id == _categoryId,
  //                     )
  //                     ? _categoryId
  //                     : null;

  //                 return DropdownButtonFormField<String>(
  //                   // initialValue: _categoryId,
  //                   initialValue: validCategory,
  //                   items: categories.map((cat) {
  //                     return DropdownMenuItem(
  //                       value: cat.id,
  //                       child: Text(cat.name),
  //                     );
  //                   }).toList(),
  //                   onChanged: (val) => setState(() => _categoryId = val),
  //                   decoration: const InputDecoration(labelText: 'Category'),
  //                 );
  //               },
  //             ),

  //           const SizedBox(height: 12),

  //           /// DATE PICKER
  //           InkWell(
  //             onTap: _pickDate,
  //             child: InputDecorator(
  //               decoration: const InputDecoration(
  //                 labelText: 'Date',
  //                 border: OutlineInputBorder(),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(_formatDate(_selectedDate)),
  //                   const Icon(Icons.calendar_today),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           const SizedBox(height: 12),

  //           /// AMOUNT
  //           TextField(
  //             controller: _amountController,
  //             keyboardType: TextInputType.number,
  //             decoration: const InputDecoration(labelText: 'Amount'),
  //           ),

  //           const SizedBox(height: 12),

  //           /// FROM ACCOUNT
  //           Consumer(
  //             builder: (context, ref, _) {
  //               final accounts = ref.watch(accountProvider);

  //               final validAccount = accounts.any((a) => a.id == _fromAccountId)
  //                   ? _fromAccountId
  //                   : null;

  //               return DropdownButtonFormField<String>(
  //                 initialValue: validAccount,
  //                 decoration: const InputDecoration(
  //                   labelText: 'From Account',
  //                 ),
  //                 items: accounts.map((acc) {
  //                   return DropdownMenuItem(
  //                     value: acc.id,
  //                     child: Text(acc.name),
  //                   );
  //                 }).toList(),
  //                 onChanged: (val) => setState(() => _fromAccountId = val),
  //               );
  //             },
  //           ),

  //           const SizedBox(height: 12),

  //           /// TO ACCOUNT (TRANSFER ONLY)
  //           if (_type == TransactionType.transfer)
  //             Consumer(
  //               builder: (context, ref, _) {
  //                 final accounts = ref.watch(accountProvider);

  //                 final validAccount = accounts.any((a) => a.id == _toAccountId)
  //                     ? _toAccountId
  //                     : null;

  //                 return DropdownButtonFormField<String>(
  //                   initialValue: validAccount,
  //                   decoration: const InputDecoration(
  //                     labelText: 'To Account',
  //                   ),
  //                   items: accounts.map((acc) {
  //                     return DropdownMenuItem(
  //                       value: acc.id,
  //                       child: Text(acc.name),
  //                     );
  //                   }).toList(),
  //                   onChanged: (val) => setState(() => _toAccountId = val),
  //                 );
  //               },
  //             ),

  //           const SizedBox(height: 12),

  //           /// NOTE
  //           TextField(
  //             controller: _noteController,
  //             decoration: const InputDecoration(labelText: 'Note'),
  //           ),

  //           const SizedBox(height: 20),

  //           /// SAVE
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: _save,
  //               child: const Text('Save'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),

      body: Column(
        children: [
          TransactionTypeSegment(
            value: _type,
            onChanged: (type) {
              HapticFeedback.selectionClick();
              setState(() {
                _type = type;
                _categoryId = null;
              });
            },
          ),

          /// HERO AMOUNT
          _amountHero(),

          /// FIELDS
          // _accountField(),
          _accountCategoryRow(),
          const SizedBox(height: 6),
          _dateTimeRow(),
          const SizedBox(height: 6),
          _noteField(),

          Spacer(),
          // Expanded(
          //   child: ListView(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [Text("dek")],
          //       ),
          //       // Expanded(
          //       //   child: Row(
          //       //     children: [
          //       //       _accountTile(),
          //       //       if (_type != TransactionType.transfer) _categoryTile(),
          //       //     ],
          //       //   ),
          //       // ),
          //       // _accountTile(),
          //       // if (_type != TransactionType.transfer) _categoryTile(),
          //       // _dateTile(),
          //       // _noteTile(),
          //     ],
          //   ),
          // ),

          // _saveButton(),
          _numericKeypad(),
        ],
      ),
    );
  }

  Color _typeColor() {
    switch (_type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }

  Widget _amountHero() {
    return Padding(
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: EdgeInsets.only(
        right: 20,
        top: 2,
        bottom: 8,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: AutoSizeText(
          formattedAmount,
          textAlign: TextAlign.right,
          maxLines: 1,

          // ukuran awal
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w600,
            color: _typeColor(),
          ),

          // autosize font
          minFontSize: 24,
          stepGranularity: 1,
          overflowReplacement: Text(
            formattedAmount,
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }

  Widget _accountField() {
    return Consumer(
      builder: (_, ref, _) {
        final accounts = ref.watch(accountProvider);

        final acc = accounts.firstWhere(
          (a) => a.id == _fromAccountId,
          orElse: () => accounts.first,
        );

        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Account",
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _accountCategoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FintechField(
              label: "Account",
              value: "Dompet",
              icon: Icons.account_balance_wallet_outlined,
              onTap: () {
                print("Giancok");
              },
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: FintechField(
              label: "Category",
              value: "Makan",
              icon: Icons.category_outlined,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _dateField(),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _timeField(),
          ),
        ],
      ),
    );
  }

  Widget _noteField() {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Note",
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: "Optional note...",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return FintechField(
      label: "Date",
      value: _formatDate(_selectedDate),
      icon: Icons.calendar_today_outlined,
      onTap: _pickDate,
    );
  }

  Widget _timeField() {
    return FintechField(
      label: "Time",
      value: "19:34",
      icon: Icons.access_time_outlined,
      onTap: () {},
    );
  }

  Widget _accountTile() {
    return Consumer(
      builder: (_, ref, _) {
        final accounts = ref.watch(accountProvider);

        final acc = accounts.firstWhere(
          (a) => a.id == _fromAccountId,
          orElse: () => accounts.first,
        );

        return ListTile(
          title: const Text("Account"),
          subtitle: Text(acc.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // open selector
          },
        );
      },
    );
  }

  Widget _categoryTile() {
    return Consumer(
      builder: (_, ref, __) {
        final categories = ref.watch(
          categoriesByTypeProvider(_type == TransactionType.income),
        );

        final cat = categories.where((c) => c.id == _categoryId).firstOrNull;

        return ListTile(
          title: const Text("Category"),
          subtitle: Text(cat?.name ?? "Select"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }

  Widget _dateTile() {
    return ListTile(
      title: const Text("Date"),
      subtitle: Text(_formatDate(_selectedDate)),
      trailing: const Icon(Icons.calendar_today),
      onTap: _pickDate,
    );
  }

  Widget _noteTile() {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(
        hintText: "Add note (optional)",
        border: InputBorder.none,
      ),
    );
  }

  Widget _saveButton() {
    final amount = int.tryParse(_amountController.text) ?? 0;

    final canSave =
        amount > 0 &&
        _fromAccountId != null &&
        (_type == TransactionType.transfer || _categoryId != null);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSave ? _save : null,
            child: const Text("Save Transaction"),
          ),
        ),
      ),
    );
  }

  Widget _numericKeypad() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
      color: context.colors.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // KeypadButton(label: '2', onTap: (){})
          _keypadRow(["7", "8", "9"]),
          _keypadRow(["4", "5", "6"]),
          _keypadRow(["1", "2", "3"]),
          _keypadRow([",", "0", "del"]),
        ],
      ),
    );
  }

  Widget _keypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: SizedBox(
              height: 64,
              child: KeypadButton(
                label: key,
                onTap: () {
                  if (key == ",") return; // optional decimal
                  _onKeyTap(key);
                },
                onLongpress: _clearAmount,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();

    setState(() {
      if (key == "del") {
        _amount = _amount ~/ 10;
        return;
      }

      final digit = int.parse(key);

      /// prevent overflow angka
      if (_amount > 999999999) return;

      _amount = (_amount * 10) + digit;
    });
  }

  void _clearAmount() {
    HapticFeedback.mediumImpact();

    setState(() {
      _amount = 0;
    });
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
