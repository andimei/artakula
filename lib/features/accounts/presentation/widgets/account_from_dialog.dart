// import 'package:artakula/features/accounts/';
import 'package:artakula/features/accounts/data/account_icons.dart';
import 'package:artakula/features/accounts/provider/account_provider.dart';
import 'package:artakula/features/categories/providers/category_provider.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/account.dart';


class AccountFormDialog extends ConsumerStatefulWidget {
  final Account? account;

  const AccountFormDialog({
    super.key,
    this.account,
  });

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  final _currencyFormat = NumberFormat.decimalPattern('id_ID');

  IconData _selectedIcon = Icons.account_balance_wallet;

  @override
  void initState() {
    super.initState();

    final acc = widget.account;

    _balanceController.addListener(_formatBalance);

    if (acc != null) {
      /// EDIT MODE
      _nameController.text = acc.name;
      _selectedIcon = acc.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.account != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Account' : 'Add Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ICON PICKER
          GestureDetector(
            onTap: _pickIcon,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _selectedIcon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// NAME
          TextField(
            controller: _nameController,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),

          if (!isEdit)
            TextField(
              controller: _balanceController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "0",
                labelText: 'Initial Balance',
              ),
            ),
        ],
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: _confirmDelete,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// SAVE
  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final accountNotifier = ref.read(accountProvider.notifier);
    final transactionNotifier = ref.read(transactionProvider.notifier);

    final balance =
        int.tryParse(
          _balanceController.text.replaceAll('.', ''),
        ) ??
        0;

    if (widget.account == null) {
      /// ADD
      final accountId = const Uuid().v4();
      accountNotifier.add(
        Account(
          id: accountId,
          name: name,
          iconCodePoint: _selectedIcon.codePoint,
        ),
      );

      /// AUTO CREATE INITIAL BALANCE TRANSACTION
      if (balance > 0) {
        final initialCategory = ref
            .read(categoryProvider)
            .firstWhere(
              (c) => c.systemKey == SystemCategory.initialBalance,
            );

        transactionNotifier.add(
          Transaction(
            id: const Uuid().v4(),
            type: TransactionType.income,
            fromAccountId: accountId,
            categoryId: initialCategory.id,
            amount: balance,
            date: DateTime.now(),
            isInitialBalance: true,
          ),
        );
      }
    } else {
      /// UPDATE
      final account = widget.account!;

      account.name = name;
      account.iconCodePoint = _selectedIcon.codePoint;
      accountNotifier.update(account);
    }

    Navigator.pop(context);
  }

  /// DELETE
  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account?"),
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
      final account = widget.account;
      if (account == null) return;

      ref.read(accountProvider.notifier).delete(account);

      if (!mounted) return;

      Navigator.pop(context);
    }
  }

  void _formatBalance() {
    String text = _balanceController.text;

    /// ambil angka saja
    text = text.replaceAll('.', '');

    if (text.isEmpty) return;

    final number = int.tryParse(text);

    /// kalau bukan angka -> stop
    if (number == null) return;

    final safeNumber = number.clamp(0, 9999999999);

    final newText = _currencyFormat.format(safeNumber);

    _balanceController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }

  /// ICON PICKER
  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: accountIcons.length,
          itemBuilder: (context, index) {
            final icon = accountIcons[index];

            return InkWell(
              onTap: () {
                setState(() => _selectedIcon = icon);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
            );
          },
        );
      },
    );
  }
}
