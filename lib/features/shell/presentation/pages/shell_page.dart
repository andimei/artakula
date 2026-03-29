// import 'package:artakula/features/accounts/presentation/pages/account_page.dart';
import 'package:artakula/features/shell/presentation/pages/more_page.dart';
import 'package:flutter/material.dart';
// import '../../../../shared/widgets/empty_tab.dart';
import '../models/tab_data.dart';
// import '../../../expenses/presentation/pages/expenses_page.dart';
import '../widgets/app_drawer.dart';
import '../../../../features/expenses/presentation/pages/expense_form_page.dart';
import '../../../../features/transactions/presentation/pages/transaction_page.dart';

class ShellPage extends StatefulWidget {
  // final ThemeMode themeMode;
  // final ValueChanged<ThemeMode> onThemeChanged;

  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  final _tabs = const [
    TabData('Transactions', Icons.receipt_long),
    // TabData('Accounts', Icons.account_balance_wallet),
    TabData('More', Icons.more_horiz),
    // TabData('Expenses', Icons.receipt_long),
    // TabData('Incomes', Icons.trending_up),
    // TabData('Transfers', Icons.swap_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('artakula')),
      drawer: AppDrawer(
        // themeMode: widget.themeMode,
        // onThemeChanged: widget.onThemeChanged,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TransactionsPage(),
          // AccountsPage(),
          MorePage(),
          // ExpensesPage(),
          // EmptyTab(title: 'Incomes'),
          // EmptyTab(title: 'Transfers'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExpenseFormPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// class ShellPage extends StatefulWidget {
//   const ShellPage({super.key});

//   @override
//   State<ShellPage> createState() => _ShellPageState();
// }

// class _ShellPageState extends State<ShellPage> {
//   int _currentIndex = 0;

//   final _tabs = const [
//     TabData('Accounts', Icons.account_balance_wallet),
//     TabData('Expenses', Icons.receipt_long),
//     TabData('Incomes', Icons.trending_up),
//     TabData('Transfers', Icons.swap_horiz),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _tabs.map((tab) => EmptyTab(title: tab.label)).toList(),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//         items: _tabs
//             .map(
//               (tab) => BottomNavigationBarItem(
//                 icon: Icon(tab.icon),
//                 label: tab.label,
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }
