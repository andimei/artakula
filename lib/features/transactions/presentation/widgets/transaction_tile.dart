import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../categories/data/models/category.dart';
import 'package:collection/collection.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;

    final categories = ref.watch(categoryProvider);
    final accounts = ref.watch(accountProvider);

    String getAccountName(String id) {
      final acc = accounts.firstWhere(
        (a) => a.id == id,
        orElse: () => Account.empty(),
      );
      return acc.name;
    }

    Category? category;

    if (transaction.categoryId != null) {
      if (transaction.categoryId != null) {
        category = categories.firstWhereOrNull(
          (c) => c.id == transaction.categoryId,
        );
      }
    }

    final color = isIncome
        ? context.semantic.income
        : isExpense
        ? context.semantic.expense
        : Colors.black;

    final sign = isIncome
        ? '+'
        : isExpense
        ? '-'
        : '';

    final title = isTransfer ? 'Transfer' : category?.name ?? 'Transaction';

    // final subtitle = isTransfer
    //     ? '${transaction.fromAccountId} to ${transaction.toAccountId}'
    //     : transaction.fromAccountId;

    final subtitle = isTransfer
        ? '${getAccountName(transaction.fromAccountId)} → ${getAccountName(transaction.toAccountId!)}'
        : getAccountName(transaction.fromAccountId);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          // borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: context.colors.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            /// Icon
            CircleAvatar(
              backgroundColor: context.colors.surface,
              child: Icon(
                isTransfer ? Icons.swap_horiz : category?.icon,
                color: context.colors.primary,
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
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return "Rp${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}";
  }
}
