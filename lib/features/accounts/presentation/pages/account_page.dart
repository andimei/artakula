// import 'package:artakula/features/accounts/presentation/widgets/account_tile.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/accounts/presentation/widgets/account_from_dialog.dart';
import 'package:artakula/features/accounts/presentation/widgets/account_header.dart';
import 'package:artakula/features/accounts/provider/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/account_tile.dart';

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
          onTap: () {
            _openForm(context, ref, account);
          },
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
}
