import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/accounts/provider/account_provider.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
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
      category = categories.firstWhereOrNull(
        (c) => c.id == transaction.categoryId,
      );
    }

    final amountColor = isIncome
        ? context.semantic.income
        : isExpense
            ? context.semantic.expense
            : context.colors.onSurface;

    final iconBgColor = isIncome
        ? context.semantic.income.withValues(alpha: 0.12)
        : isExpense
            ? context.semantic.expense.withValues(alpha: 0.12)
            : context.colors.primaryContainer;

    final iconColor = isIncome
        ? context.semantic.income
        : isExpense
            ? context.semantic.expense
            : context.colors.onPrimaryContainer;

    final sign = isIncome ? '+' : isExpense ? '-' : '';

    final title = isTransfer ? 'Transfer' : category?.name ?? 'Transaction';

    final subtitle = isTransfer
        ? '${getAccountName(transaction.fromAccountId)} → ${getAccountName(transaction.toAccountId!)}'
        : getAccountName(transaction.fromAccountId);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconBgColor,
                child: Icon(
                  isTransfer ? Icons.swap_horiz : category?.icon ?? Icons.receipt,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Text(
                "$sign${formatRupiah(transaction.amount)}",
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
