import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(filteredTransactionProvider(_currentMonth));

    final income = ref.watch(totalIncomeProvider(_currentMonth));
    final expense = ref.watch(totalExpenseProvider(_currentMonth));
    final balance = ref.watch(balanceProvider(_currentMonth));

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,

      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
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
        child: const Icon(Icons.add),
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
          const SizedBox(height: 12),
          _summaryCard(context, income, expense, balance),
          const SizedBox(height: 12),

          Expanded(
            child: _buildGroupedList(txs),
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
    return DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth);
  }

  /// MONTH SWITCHER
  Widget _monthSwitcher(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _prevMonth,
              style: IconButton.styleFrom(
                foregroundColor: context.colors.primary,
              ),
            ),

            GestureDetector(
              onTap: () async {
                final picked = await openMonthYearPicker(
                  context,
                  _currentMonth,
                );
                if (!mounted || picked == null) return;
                setState(() => _currentMonth = picked);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _monthLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _nextMonth,
              style: IconButton.styleFrom(
                foregroundColor: context.colors.primary,
              ),
            ),
          ],
        ),
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
              title: const Text("Pilih Bulan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            child: Text([
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
                            ][index]),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => selectedMonth = month);
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth),
                    );
                  },
                  child: const Text("Pilih"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// SUMMARY CARD
  Widget _summaryCard(
      BuildContext context, int income, int expense, int balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _summaryRow(
              context,
              "Pemasukan",
              "+",
              income,
              context.semantic.income,
              Icons.arrow_upward_rounded,
            ),
            const SizedBox(height: 8),
            _summaryRow(
              context,
              "Pengeluaran",
              "-",
              expense,
              context.semantic.expense,
              Icons.arrow_downward_rounded,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: context.colors.outlineVariant.withValues(alpha: 0.4),
                height: 1,
              ),
            ),
            _summaryRow(
              context,
              "Saldo",
              "",
              balance,
              context.colors.onSurface,
              Icons.account_balance_wallet_rounded,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String title,
    String sign,
    int value,
    Color color,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 13 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          "$sign${formatRupiah(value)}",
          textAlign: TextAlign.end,
          style: TextStyle(
            color: color,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            fontSize: isTotal ? 15 : 14,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedList(List<Transaction> txs) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final tx in txs) {
      final date = tx.dateOnly;
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(tx);
    }

    for (final list in grouped.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }

    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _scrollController,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _dayHeader(context, day, total),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TransactionTile(
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
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  Widget _dayHeader(BuildContext context, DateTime day, int total) {
    final date = DateFormat('d').format(day);
    final weekday = DateFormat('EEEE', 'id_ID').format(day);

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              date,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              weekday,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            formatRupiah(total),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: total >= 0
                  ? context.semantic.income
                  : context.semantic.expense,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
