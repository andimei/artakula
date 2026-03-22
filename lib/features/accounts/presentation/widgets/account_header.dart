import 'package:flutter/material.dart';

class AccountsHeader extends StatelessWidget {
  const AccountsHeader({
    super.key,
    required this.onAdd,
    this.onFilter,
    this.onSettings,
  });

  final VoidCallback onAdd;
  final VoidCallback? onFilter;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        children: [
          const Text(
            'Accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Account',
            onPressed: onAdd,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: onFilter,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}
