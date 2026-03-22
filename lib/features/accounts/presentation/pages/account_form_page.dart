import 'package:flutter/material.dart';
import '../widgets/account_form.dart';
import '../../data/models/account.dart';

class AccountFormPage extends StatelessWidget {
  final Account? account;

  AccountFormPage({super.key, this.account});

  final _formKey = GlobalKey<AccountFormState>();

  bool get isEdit => account != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Account' : 'Add Account'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _formKey.currentState?.confirmDelete(),
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _formKey.currentState?.submit(),
          ),
        ],
      ),
      body: AccountForm(
        key: _formKey,
        account: account,
      ),
    );
  }
}
