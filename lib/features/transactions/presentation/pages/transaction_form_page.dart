import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/transactions/presentation/pages/account_picker_page.dart';
import 'package:artakula/features/transactions/presentation/pages/category_picker_page.dart';
import 'package:artakula/features/transactions/presentation/widgets/account_picker.dart';
import 'package:artakula/features/transactions/presentation/widgets/fintech_field.dart';
import 'package:artakula/features/transactions/presentation/widgets/keypad_button.dart';
import 'package:artakula/features/transactions/presentation/widgets/numeric_keypad.dart';
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
      print("GIANCOK");
      _selectedDate = DateTime.now(); // default hari ini
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          isEdit
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.red,
                    iconSize: 32,
                    minimumSize: const Size(56, 56), // ukuran tombol
                  ),
                )
              : SizedBox.shrink(),
        ],
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
          _accountCategoryRow(ref),
          const SizedBox(height: 6),
          _dateTimeRow(),
          const SizedBox(height: 6),
          _noteField(),

          /// ========= SAVE BUTTON =========
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: keyboardOpen
                ? const SizedBox.shrink()
                : NumericKeypad(
                    onKeyTap: _onKeyTap,
                    onClear: _clearAmount,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete transaction?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      // ref.read(transactionProvider.notifier).delete(widget.transaction.id);

      Navigator.pop(context);
    }
  }

  Widget _keypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: KeypadButton(
                label: key,
                onTap: () {
                  if (key == ",") return;
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

  // Widget _accountCategoryRow() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: FintechField(
  //             label: "Account",
  //             value: "Dompet",
  //             icon: Icons.account_balance_wallet_outlined,
  //             onTap: () async {
  //               final account = await openAccountPicker(
  //                 context,
  //                 selectedId: _toAccountId,
  //               );

  //               if (account != null) {
  //                 setState(() {
  //                   _toAccountId = account.id;
  //                 });
  //               }
  //             },
  //           ),
  //         ),

  //         const SizedBox(width: 6),

  //         Expanded(
  //           child: FintechField(
  //             label: "Category",
  //             value: "Makan",
  //             icon: Icons.category_outlined,
  //             onTap: () {},
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _accountCategoryRow(WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final categories = ref.watch(categoryProvider);

    // final selectedAccount = accounts
    //     .where((a) => a.id == _toAccountId)
    //     .firstOrNull;

    final selectedAccount = accounts
        .where((a) => a.id == _fromAccountId)
        .firstOrNull;

    final selectedCategory = categories
        .where((c) => c.id == _categoryId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          /// ACCOUNT
          Expanded(
            child: FintechField(
              label: "Account",
              value: selectedAccount?.name ?? "Select account",
              icon: Icons.account_balance_wallet_outlined,
              onTap: () async {
                final account = await openAccountPicker(
                  context,
                  selectedId: _fromAccountId,
                );

                if (account != null) {
                  setState(() => _fromAccountId = account.id);
                }
              },
            ),
          ),

          const SizedBox(width: 6),

          /// CATEGORY
          Expanded(
            child: FintechField(
              label: "Category",
              value: selectedCategory?.name ?? "Select category",
              icon: Icons.category_outlined,
              onTap: () async {
                final category = await openCategoryPicker(
                  context,
                  type: _type,
                  selectedId: _categoryId,
                );

                if (category != null) {
                  setState(() => _categoryId = category.id);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Account?> openAccountPicker(
    BuildContext context, {
    String? selectedId,
  }) {
    return Navigator.push<Account>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountPickerPage(
          selectedId: selectedId,
        ),
      ),
    );
  }

  Future<Category?> openCategoryPicker(
    BuildContext context, {
    required TransactionType type,
    String? selectedId,
  }) {
    return Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(
          type: type,
          selectedId: selectedId,
        ),
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
                // hintText: "Optional note...",
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

  // Widget _saveButton() {
  //   final amount = int.tryParse(formattedAmount) ?? 0;

  //   final canSave =
  //       amount > 0 &&
  //       _fromAccountId != null &&
  //       (_type == TransactionType.transfer || _categoryId != null);

  //   return SafeArea(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: SizedBox(
  //         width: double.infinity,
  //         child: FilledButton(
  //           onPressed: canSave ? _save : null,
  //           child: const Text("Save Transaction"),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _numericKeypad() {
  //   return Container(
  //     padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
  //     color: context.colors.surfaceContainerHighest,
  //     child: Column(
  //       // mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // KeypadButton(label: '2', onTap: (){})
  //         _keypadRow(["7", "8", "9"]),
  //         _keypadRow(["4", "5", "6"]),
  //         _keypadRow(["1", "2", "3"]),
  //         _keypadRow([",", "0", "del"]),
  //       ],
  //     ),
  //   );
  // }

  // Widget _keypadRow(List<String> keys) {
  //   return Row(
  //     children: keys.map((key) {
  //       return Expanded(
  //         child: Padding(
  //           padding: const EdgeInsets.all(1),
  //           child: SizedBox(
  //             height: 64,
  //             child: KeypadButton(
  //               label: key,
  //               onTap: () {
  //                 if (key == ",") return; // optional decimal
  //                 _onKeyTap(key);
  //               },
  //               onLongpress: _clearAmount,
  //             ),
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

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

  // void _save() {
  //   // final amount = int.tryParse(_amountController.text) ?? 0;
  //   final amount = int.tryParse(formattedAmount) ?? 0;

  //   if (_fromAccountId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Select account')),
  //     );
  //     return;
  //   }

  //   if (_type != TransactionType.transfer && _categoryId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Select category')),
  //     );
  //     return;
  //   }

  //   final notifier = ref.read(transactionProvider.notifier);

  //   if (widget.transaction == null) {
  //     // ===== ADD =====
  //     final tx = Transaction(
  //       id: const Uuid().v4(),
  //       type: _type,
  //       amount: amount,
  //       date: _selectedDate,
  //       categoryId: _type == TransactionType.transfer ? null : _categoryId,
  //       fromAccountId: _fromAccountId!,
  //       toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
  //       note: _noteController.text,
  //     );

  //     notifier.add(tx);
  //   } else {
  //     // ===== UPDATE =====
  //     final tx = widget.transaction!;

  //     tx.type = _type;
  //     tx.amount = amount;
  //     tx.date = _selectedDate;
  //     tx.categoryId = _type == TransactionType.transfer ? null : _categoryId;
  //     tx.fromAccountId = _fromAccountId!;
  //     tx.toAccountId = _type == TransactionType.transfer ? _toAccountId : null;
  //     tx.note = _noteController.text;

  //     notifier.update(tx);
  //   }

  //   Navigator.pop(context);
  // }
  void _save() {
    // final amount = int.tryParse(formattedAmount) ?? 0;

    // print(_amount);
    // return;

    /// ===== VALIDATION =====

    if (_amount <= 0) {
      _error("Amount must be greater than 0");
      return;
    }

    if (_fromAccountId == null) {
      _error("Select account");
      return;
    }

    /// transfer validation
    if (_type == TransactionType.transfer) {
      if (_toAccountId == null) {
        _error("Select destination account");
        return;
      }

      if (_fromAccountId == _toAccountId) {
        _error("Cannot transfer to same account");
        return;
      }
    }

    /// category validation
    if (_type != TransactionType.transfer && _categoryId == null) {
      _error("Select category");
      return;
    }

    final notifier = ref.read(transactionProvider.notifier);

    /// ===== ADD =====
    if (widget.transaction == null) {
      final tx = Transaction(
        id: const Uuid().v4(),
        type: _type,
        amount: _amount,
        date: _selectedDate,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        fromAccountId: _fromAccountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        note: _noteController.text.trim(),
      );

      notifier.add(tx);
    }
    /// ===== UPDATE (IMMUTABLE) =====
    else {
      final old = widget.transaction!;

      final updated = old.copyWith(
        type: _type,
        amount: _amount,
        date: _selectedDate,
        categoryId: _type == TransactionType.transfer ? null : _categoryId,
        fromAccountId: _fromAccountId!,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        note: _noteController.text.trim(),
      );

      notifier.update(updated);
    }

    Navigator.pop(context);
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
