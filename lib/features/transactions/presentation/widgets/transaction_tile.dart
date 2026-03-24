import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    final color = isIncome
        ? Colors.green
        : isExpense
        ? Colors.red
        : Colors.blueGrey;

    final sign = isIncome
        ? '+'
        : isExpense
        ? '-'
        : '';

    final title = isTransfer
        ? 'Transfer'
        : transaction.note.isNotEmpty
        ? transaction.note
        : transaction.categoryId ?? 'Transaction';

    final subtitle = isTransfer
        ? '${transaction.fromAccountId} → ${transaction.toAccountId}'
        : transaction.fromAccountId;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// Icon
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward
                    : isExpense
                    ? Icons.arrow_upward
                    : Icons.swap_horiz,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            /// Amount
            Text(
              "$sign${_formatCurrency(transaction.amount)}",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return "IDR ${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }
}
