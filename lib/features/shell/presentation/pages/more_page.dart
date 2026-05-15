import 'package:artakula/features/accounts/presentation/pages/account_page.dart';
import 'package:artakula/features/budgets/presentation/pages/budget_page.dart';
import 'package:flutter/material.dart';
import '../../../categories/presentation/pages/category_page.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _SectionHeader(title: "Data Master"),
        _MenuItem(
          icon: Icons.account_balance_wallet,
          title: "Accounts",
          onTap: () => _push(context, const AccountsPage()),
        ),
        _MenuItem(
          icon: Icons.category,
          title: "Categories",
          onTap: () => _push(context, const CategoriesPage()),
        ),
        _MenuItem(
          icon: Icons.pie_chart,
          title: "Budgets",
          onTap: () => _push(context, const BudgetsPage()),
        ),

        const _SectionHeader(title: "Pengaturan"),
        _MenuItem(
          icon: Icons.settings,
          title: "Settings",
          onTap: () => _push(context, const SettingsPage()),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
