import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
// import 'package:artakula/features/transactions/providers/transaction_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_filter_page.dart';
import 'transaction_form_page.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(filteredTransactionProvider(_currentMonth));

    final income = ref.watch(totalIncomeProvider(_currentMonth));
    final expense = ref.watch(totalExpenseProvider(_currentMonth));
    final balance = ref.watch(balanceProvider(_currentMonth));

    final monthTxs = txs.where((tx) {
      return tx.date.year == _currentMonth.year &&
          tx.date.month == _currentMonth.month;
    }).toList();

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
            child: _buildGroupedList(monthTxs),
          ),
        ],
      ),
    );
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String get _monthLabel {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return "${months[_currentMonth.month - 1]} ${_currentMonth.year}";
  }

  /// MONTH SWITCHER
  Widget _monthSwitcher(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevMonth,
          ),

          GestureDetector(
            // onTap: _pickMonth,
            onTap: () async {
              final picked = await openMonthYearPicker(
                context,
                _currentMonth,
              );

              if (!mounted || picked == null) return;

              setState(() {
                _currentMonth = picked;
              });
            },
            child: Text(
              _monthLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Future<DateTime?> openMonthYearPicker(
    BuildContext context,
    DateTime initial,
  ) {
    int selectedYear = initial.year;
    int selectedMonth = initial.month;

    return showDialog<DateTime>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Month"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// YEAR PICKER
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(
                      81,
                      (i) {
                        final year = 2020 + i;
                        return DropdownMenuItem(
                          value: year,
                          child: Text("$year"),
                        );
                      },
                    ),
                    onChanged: (val) {
                      setState(() => selectedYear = val!);
                    },
                  ),

                  const SizedBox(height: 12),

                  /// MONTH GRID
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (index) {
                      final month = index + 1;

                      final isSelected = month == selectedMonth;

                      return ChoiceChip(
                        showCheckmark: false,
                        label: SizedBox(
                          width: 28, 
                          child: Center(
                            child: Text(
                              [
                                "Jan",
                                "Feb",
                                "Mar",
                                "Apr",
                                "Mei",
                                "Jun",
                                "Jul",
                                "Agu",
                                "Sep",
                                "Okt",
                                "Nov",
                                "Des",
                              ][index],
                            ),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedMonth = month;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
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
          _row("Income", "+", income, context.semantic.income),
          _row("Expense", "-", expense, context.semantic.expense),
          Divider(color: context.colors.outlineVariant, height: 2),
          _row(
            "Total",
            "",
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
    String sign,
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
            _formatCurrency(sign, value),
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

    for (final tx in txs) {
      final date = tx.dateOnly;

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(tx);
    }

    /// SORT transaksi dalam tiap hari
    for (final list in grouped.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }

    /// SORT hari terbaru di atas
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
            Divider(
              color: context.colors.outlineVariant,
              height: 2,
            ),

            /// newest transaction first
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
      // color: context.colors.surfaceContainer,
      color: context.colors.surfaceContainerLow,
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
                  // color: context.colors.primary,
                  // color: Colors.black,
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
          Text(_formatCurrency("", total)),
        ],
      ),
    );
  }

  String _formatCurrency(String sign, int value) {
    return "${sign}Rp${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }
}
