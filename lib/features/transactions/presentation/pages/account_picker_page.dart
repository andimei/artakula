import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../providers/account_provider.dart';
import '../../../accounts/controller/account_provider.dart';
// import '../../data/models/account.dart';
import '../../../accounts/data/models/account.dart';

class AccountPickerPage extends ConsumerWidget {
  final String? selectedId;

  const AccountPickerPage({
    super.key,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          /// nanti buka add account
        },
        child: const Icon(Icons.add),
      ),

      body: ListView.separated(
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final acc = accounts[index];

          final isSelected = acc.id == selectedId;

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                // color: acc.color,
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ),
            ),

            title: Text(
              acc.name,
              style: const TextStyle(fontSize: 16),
            ),

            // subtitle: Text(acc.groupName ?? "General"),
            subtitle: Text("General"),

            trailing:
                isSelected ? const Icon(Icons.check, color: Colors.green) : null,

            onTap: () {
              Navigator.pop(context, acc);
            },
          );
        },
      ),
    );
  }
}