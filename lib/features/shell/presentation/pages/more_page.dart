import 'package:artakula/features/accounts/presentation/pages/account_page.dart';
import 'package:artakula/features/budgets/presentation/pages/budget_page.dart';
import 'package:flutter/material.dart';
import '../../../categories/presentation/pages/category_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _menuItem(
          context,
          icon: Icons.account_balance_wallet,
          title: "Accounts",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AccountsPage(),
              ),
            );
          },
        ),

        _menuItem(
          context,
          icon: Icons.category,
          title: "Categories",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesPage(),
              ),
            );
          },
        ),

        _menuItem(
          context,
          icon: Icons.pie_chart,
          title: "Butgets",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BudgetsPage(),
              ),
            );
          },
        ),

        // nanti bisa tambah:
        // Budget
        // Settings
        // dll
      ],
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
