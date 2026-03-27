import 'package:flutter/material.dart';
import '../widgets/account_form.dart';
import '../widgets/account_form_controller.dart';
import '../../data/models/account.dart';

class AccountFormPage extends StatefulWidget {
  final Account? account;

  const AccountFormPage({super.key, this.account});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  late final AccountFormController controller;

  bool get isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    controller = AccountFormController();
  }

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
              onPressed: controller.delete,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: controller.submit,
          ),
        ],
      ),
      body: AccountForm(
        account: widget.account,
        controller: controller,
      ),
    );
  }
}
