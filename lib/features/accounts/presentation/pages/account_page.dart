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

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  @override
  Widget build(BuildContext context) {
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
                  child: _buildList(context, accounts),
                ),
                // _buildList(context, accounts),
                // Expanded(
                //   child: ListView.separated(
                //     padding: const EdgeInsets.all(12),
                //     itemCount: accounts.length,
                //     separatorBuilder: (_, __) => const SizedBox(height: 3),
                //     itemBuilder: (context, index) {
                //       final account = accounts[index];

                //       return Dismissible(
                //         key: ValueKey(account.id),
                //         direction: DismissDirection.endToStart,
                //         background: _deleteBackground(),
                //         onDismissed: (_) {
                //           ref.read(accountProvider.notifier).delete(account);
                //         },
                //         child: AccountTile(
                //           account: account,
                //           onTap: () => _openForm(context, ref, account),
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Account> accounts,
  ) {
    final filtered = accounts.toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    if (filtered.isEmpty) {
      return const Center(child: Text('No categories'));
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),

      itemCount: filtered.length,

      onReorder: (oldIndex, newIndex) =>
          _onReorder(filtered, oldIndex, newIndex),

      itemBuilder: (context, index) {
        final account = filtered[index];

        return AccountTile(
          key: ValueKey(account.id),
          account: account,

          dragHandle: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.dehaze, color: Colors.grey),
          ),
          // onTap: () {
          //   _openForm(context, category, isIncome);
          // },
        );
      },
    );
  }

  Future<void> _onReorder(
    List<Account> list,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    /// update order hanya group ini
    for (int i = 0; i < list.length; i++) {
      list[i].order = i;
    }

    await Future.wait(list.map((c) => c.save()));

    setState(() {});
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
