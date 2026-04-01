import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:flutter/material.dart';

class AccountPicker extends StatelessWidget {
  final Account? selected;
  final List<Account> accounts;
  final ValueChanged<Account> onSelected;

  const AccountPicker({
    super.key,
    required this.selected,
    required this.accounts,
    required this.onSelected,
  });

  void _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<Account>(
      context: context,
      showDragHandle: true,
      builder: (_) => AccountPickerSheet(
        accounts: accounts,
        selected: selected,
      ),
    );

    if (result != null) {
      onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon(selected?.icon ?? Icons.account_balance_wallet),
            Icon(Icons.account_balance_wallet),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                selected?.name ?? "Select Account",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}


class AccountPickerSheet extends StatelessWidget {
  final List<Account> accounts;
  final Account? selected;

  const AccountPickerSheet({
    super.key,
    required this.accounts,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final acc = accounts[i];
          final isSelected = acc.id == selected?.id;

          return ListTile(
            // leading: Icon(acc.icon),
            leading: Icon(Icons.account_balance_wallet),
            title: Text(acc.name),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, acc),
          );
        },
      ),
    );
  }
}
