import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/account.dart';
import '../../controller/account_provider.dart';

// import 'package:flutter/material.dart';
// import '../../data/models/account.dart';

// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';

// import '../../data/models/account.dart';
// import '../../controller/account_provider.dart';

class AccountForm extends ConsumerStatefulWidget {
  final Account? account;

  const AccountForm({
    super.key,
    this.account,
  });

  @override
  ConsumerState<AccountForm> createState() => AccountFormState();
}

class AccountFormState extends ConsumerState<AccountForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _balanceCtrl;

  bool get isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.account?.name ?? '');
    _balanceCtrl = TextEditingController(
      text: widget.account?.balance.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  // dipanggil dari AppBar
  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final balance = int.parse(_balanceCtrl.text);

    if (isEdit) {
      widget.account!
        ..name = _nameCtrl.text
        ..balance = balance
        ..save();
    } else {
      ref
          .read(accountProvider.notifier)
          .add(
            Account(
              id: const Uuid().v4(),
              name: _nameCtrl.text,
              balance: balance,
            ),
          );
    }

    Navigator.pop(context);
  }

  // dipanggil dari AppBar
  void delete() {
    if (!isEdit) return;
    ref.read(accountProvider.notifier).delete(widget.account!);
    Navigator.pop(context);
  }

  Future<void> confirmDelete() async {
    if (!isEdit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This action cannot be undone. '
          'All related records will be permanently removed.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Account name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Initial balance'),
              validator: (v) => v == null || int.tryParse(v) == null
                  ? 'Invalid number'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
