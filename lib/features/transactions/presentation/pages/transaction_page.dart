import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/transaction_filter_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_form_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(filteredTransactionProvider); // 🔥 pakai filter
    final filter = ref.watch(transactionFilterProvider);

    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _header(income, expense, balance),

          /// 🔥 FILTER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _filterChip(ref, TransactionFilter.all, "All"),
                _filterChip(ref, TransactionFilter.today, "Today"),
                _filterChip(ref, TransactionFilter.thisMonth, "Month"),
              ],
            ),
          ),

          Expanded(
            child: txs.isEmpty
                ? const Center(child: Text('No transactions yet'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: txs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = txs[index];

                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.startToEnd,
                        background: _deleteBackground(),
                        onDismissed: (_) {
                          ref
                              .read(transactionProvider.notifier)
                              .deleteWithUndo(context, tx);
                        },
                        child: TransactionTile(
                          transaction: tx,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TransactionFormPage(transaction: tx),
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

  /// 🔴 HEADER
  Widget _header(int income, int expense, int balance) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Today",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Income", income, Colors.green),
                _divider(),
                _summaryItem("Expenses", expense, Colors.red),
                _divider(),
                _summaryItem("Balance", balance, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 FILTER CHIP
  Widget _filterChip(
    WidgetRef ref,
    TransactionFilter value,
    String label,
  ) {
    final selected = ref.watch(transactionFilterProvider) == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        ref.read(transactionFilterProvider.notifier).state = value;
      },
    );
  }

  Widget _summaryItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey[300],
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  String _formatCurrency(int value) {
    return "IDR ${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }
}
