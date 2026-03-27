import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/account.dart';
import '../../controller/account_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'account_form_controller.dart';

class AccountForm extends ConsumerStatefulWidget {
  final Account? account;
  final AccountFormController controller;

  const AccountForm({
    super.key,
    this.account,
    required this.controller,
  });

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _currencyFormat = NumberFormat.decimalPattern('id_ID');
  bool get isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();

    final acc = widget.account;
    if (acc != null) {
      _nameController.text = acc.name;
      _balanceController.text = _currencyFormat.format(acc.initialBalance);
    }
    _balanceController.addListener(_formatBalance);

    widget.controller.bind(
      onSubmit: _submit,
      onDelete: _confirmDelete,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            /// FORM
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// ACCOUNT
                  const Text(
                    "ACCOUNT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Cash, Bank, etc",
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// INITIAL BALANCE (ONLY CREATE MODE)
                  if (!isEdit) ...[
                    const Text(
                      "INITIAL BALANCE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// BUTTON SIMPAN
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2C5F73),
                          Color(0xFF3FA2D6),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final notifier = ref.read(accountProvider.notifier);

    if (!isEdit) {
      notifier.add(
        Account(
          id: const Uuid().v4(),
          name: _nameController.text,
          initialBalance: int.parse(
            _balanceController.text.replaceAll('.', ''),
          ),
        ),
      );
    } else {
      final acc = widget.account!;
      acc.name = _nameController.text;

      /// JANGAN EDIT INITIAL BALANCE
      notifier.update(acc);
    }

    Navigator.pop(context);
  }

  void _confirmDelete() {
    final acc = widget.account;
    if (acc == null) return;

    ref.read(accountProvider.notifier).delete(acc);
    Navigator.pop(context);
  }

  void _formatBalance() {
    String text = _balanceController.text;

    /// ambil angka saja
    text = text.replaceAll('.', '');

    if (text.isEmpty) return;

    final number = int.parse(text);

    final newText = _currencyFormat.format(number);

    _balanceController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newText.length,
      ),
    );
  }
}
