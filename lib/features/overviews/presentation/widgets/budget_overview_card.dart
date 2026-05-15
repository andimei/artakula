import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:artakula/features/budgets/providers/budget_overview_provider.dart';
import 'package:artakula/features/budgets/providers/budget_provider.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetOverviewCard extends ConsumerWidget {
  const BudgetOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetProvider);

    if (budgets.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final overviews = ref.watch(budgetOverviewProvider(now));

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: context.colors.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget Tracker',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          ...overviews.map((b) => _BudgetProgressItem(context: context, data: b)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BudgetFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Budget'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: context.colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressItem extends StatelessWidget {
  final BuildContext context;
  final BudgetWithSpending data;

  const _BudgetProgressItem({
    required this.context,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final b = data.budget;
    final progress = data.progress;
    final isOverspent = data.isOverspent;
    final barColor = isOverspent
        ? context.semantic.expense
        : progress > 0.8
            ? Colors.orange
            : context.colors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isOverspent
                    ? context.semantic.expense.withValues(alpha: 0.12)
                    : context.colors.primaryContainer,
                child: Icon(
                  data.category?.icon ?? Icons.receipt_outlined,
                  size: 14,
                  color: isOverspent
                      ? context.semantic.expense
                      : context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatRupiah(data.spent),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ' / ${formatRupiah(b.amount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (isOverspent)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${formatRupiah(data.remaining.abs())} overspent',
                style: TextStyle(
                  fontSize: 11,
                  color: context.semantic.expense,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
