import 'package:flutter/material.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
