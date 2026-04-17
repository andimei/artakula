import 'package:artakula/features/accounts/presentation/widgets/account_from_dialog.dart';
import 'package:artakula/features/accounts/provider/account_provider.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AccountPickerPage extends ConsumerWidget {
  final String? selectedId;

  const AccountPickerPage({
    super.key,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);

    final filtered = accounts.toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    // accounts
    //   ..sort(
    //     (a, b) => (a.order ?? 0).compareTo(b.order ?? 0),
    //   );

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        // backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),

      body: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          color: Color.fromARGB(255, 226, 226, 226),
          indent: 18,
          endIndent: 18,
        ),
        itemBuilder: (context, index) {
          final acc = filtered[index];
          final balance = ref.watch(accountBalanceProvider(acc.id));
          final isSelected = acc.id == selectedId;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),

            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                // color: acc.color,
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                acc.icon,
                color: Colors.white,
              ),
            ),

            title: Text(
              acc.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              rupiah.format(balance),
            ),

            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,

            onTap: () {
              Navigator.pop(context, acc);
            },
          );
        },
      ),
    );
  }

  /// OPEN FORM
  void _openForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AccountFormDialog(),
    );
  }
}
