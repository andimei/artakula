import 'package:artakula/features/overviews/presentation/pages/overview_page.dart';
import 'package:artakula/features/shell/presentation/pages/more_page.dart';
import 'package:flutter/material.dart';
import '../models/tab_data.dart';
import '../../../../features/transactions/presentation/pages/transaction_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  final _tabs = const [
    TabData('Transactions', Icons.receipt_long),
    TabData('Overviews', Icons.assessment_outlined),
    TabData('More', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TransactionsPage(),
          OverviewPage(),
          MorePage(),
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
    );
  }
}
