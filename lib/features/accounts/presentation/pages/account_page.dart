// import 'package:artakula/features/accounts/presentation/widgets/account_tile.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/accounts/presentation/widgets/account_from_dialog.dart';
import 'package:artakula/features/accounts/presentation/widgets/account_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/account_provider.dart';
// import '../widgets/account_header.dart';
// import '../widgets/account_form.dart';
import '../widgets/account_tile.dart';
import 'package:artakula/features/accounts/presentation/pages/account_form_page.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        heroTag: null,

        onPressed: () => _openForm(context, ref, null),
        // onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       // builder: (_) => AccountFormPage(),
        //       builder: (_) => AccountFormDialog(),
        //     ),
        //   );
        // },
        child: const Icon(Icons.add),
      ),
      body: accounts.isEmpty
          ? const Center(child: Text('No accounts yet'))
          : Column(
              children: [
                Container(
                  // padding: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: const AccountHeader(),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 3),
                    itemBuilder: (context, index) {
                      final account = accounts[index];

                      return Dismissible(
                        key: ValueKey(account.id),
                        direction: DismissDirection.endToStart,
                        background: _deleteBackground(),
                        onDismissed: (_) {
                          ref.read(accountProvider.notifier).delete(account);
                        },
                        child: AccountTile(
                          account: account,
                          // onTap: _openForm(context, ref, account),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountFormPage(account: account),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// OPEN FORM
  void _openForm(
    BuildContext context,
    WidgetRef ref, [
    Account? account,
  ]) {
    showDialog(
      context: context,
      builder: (_) => AccountFormDialog(
        account: account,
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
