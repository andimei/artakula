// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../providers/transaction_provider.dart';
// import '../../providers/transaction_filter_provider.dart';
// import '../widgets/transaction_tile.dart';
// import 'transaction_form_page.dart';

// class TransactionsPage extends ConsumerWidget {
//   const TransactionsPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final txs = ref.watch(filteredTransactionProvider); // 🔥 pakai filter
//     // final filter = ref.watch(transactionFilterProvider);

//     final income = ref.watch(totalIncomeProvider);
//     final expense = ref.watch(totalExpenseProvider);
//     final balance = ref.watch(balanceProvider);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.pink,
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const TransactionFormPage(),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Column(
//         children: [
//           _header(income, expense, balance),

//           /// 🔥 FILTER
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _filterChip(ref, TransactionFilter.all, "All"),
//                 _filterChip(ref, TransactionFilter.today, "Today"),
//                 _filterChip(ref, TransactionFilter.thisMonth, "Month"),
//               ],
//             ),
//           ),

//           Expanded(
//             child: txs.isEmpty
//                 ? const Center(child: Text('No transactions yet'))
//                 : ListView.separated(
//                     // padding: const EdgeInsets.all(12),
//                     padding: EdgeInsets.only(
//                       bottom: MediaQuery.of(context).padding.bottom + 80,
//                     ),
//                     itemCount: txs.length,
//                     separatorBuilder: (_, _) => const SizedBox(height: 2),
//                     itemBuilder: (context, index) {
//                       final tx = txs[index];

//                       return TransactionTile(
//                         transaction: tx,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   TransactionFormPage(transaction: tx),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// HEADER
//   Widget _header(int income, int expense, int balance) {
//     return Container(
//       padding: const EdgeInsets.only(top: 50, bottom: 16),
//       decoration: const BoxDecoration(
//         color: Colors.pink,
//         borderRadius: BorderRadius.vertical(
//           bottom: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             "Today",
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _summaryItem("Income", income, Colors.green),
//                 _divider(),
//                 _summaryItem("Expenses", expense, Colors.red),
//                 _divider(),
//                 _summaryItem("Balance", balance, Colors.green),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   ///  FILTER CHIP
//   Widget _filterChip(
//     WidgetRef ref,
//     TransactionFilter value,
//     String label,
//   ) {
//     final selected = ref.watch(transactionFilterProvider) == value;

//     return ChoiceChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: (_) {
//         ref.read(transactionFilterProvider.notifier).state = value;
//       },
//     );
//   }

//   Widget _summaryItem(String title, int value, Color color) {
//     return Column(
//       children: [
//         Text(title, style: const TextStyle(color: Colors.grey)),
//         const SizedBox(height: 4),
//         Text(
//           _formatCurrency(value),
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _divider() {
//     return Container(
//       width: 1,
//       height: 30,
//       color: Colors.grey[300],
//     );
//   }

//   String _formatCurrency(int value) {
//     return "IDR ${value.toString().replaceAllMapped(
//       RegExp(r'\B(?=(\d{3})+(?!\d))'),
//       (match) => '.',
//     )}";
//   }
// }

import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_filter_page.dart';
import 'transaction_form_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(filteredTransactionProvider);

    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,

      /// APPBAR
      appBar: AppBar(
        title: const Text("Transactions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // next step search delegate
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionFilterPage(),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormPage(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          _monthSwitcher(context),
          _summary(context, income, expense, balance),
          const SizedBox(height: 8),

          Expanded(
            child: _buildGroupedList(txs),
          ),
        ],
      ),
    );
  }

  /// MONTH SWITCHER
  Widget _monthSwitcher(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left),
          Text(
            "Maret 2026",
            style: TextStyle(
              fontSize: 16,
              color: context.colors.primary,
            ),
          ),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  /// SUMMARY
  Widget _summary(BuildContext context, int income, int expense, int balance) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      child: Column(
        children: [
          _row("Income", income, Colors.green),
          _row("Expense", -expense, context.colors.shadow),
          Divider(color: context.colors.outlineVariant, height: 2),
          _row(
            "Total",
            balance,
            Colors.black,
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            valueStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              // fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    int value,
    Color color, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Text(
            _formatCurrency(value),
            style:
                valueStyle ??
                TextStyle(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<Transaction> txs) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final Transaction tx in txs) {
      final date = tx.dateOnly;

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(tx);
    }

    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final day = keys[index];
        final items = grouped[day]!;

        final total = items.fold<int>(
          0,
          (sum, tx) => sum + tx.signedAmount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dayHeader(context, day, total),
            ...items.map(
              (tx) => TransactionTile(
                transaction: tx,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionFormPage(transaction: tx),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _dayHeader(BuildContext context, DateTime day, int total) {
    final date = DateFormat('d').format(day);
    final weekday = DateFormat('EEEE', 'id_ID').format(day);
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(day);

    return Container(
      padding: const EdgeInsets.all(12),
      color: context.colors.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    monthYear,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Text(_formatCurrency(total)),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    final abs = value.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    if (value < 0) {
      return "-$abs";
    }

    return abs;
  }
}
