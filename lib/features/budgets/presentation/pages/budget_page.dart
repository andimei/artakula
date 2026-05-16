import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/budgets/providers/budget_provider.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/providers/category_provider.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'budget_form_page.dart';

class BudgetsPage extends ConsumerStatefulWidget {
  const BudgetsPage({super.key});

  @override
  ConsumerState<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends ConsumerState<BudgetsPage> {
  List<Budget> _sorted = [];

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetProvider);
    final categories = ref.watch(categoryProvider);

    _sorted = [...budgets]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    final totalBudget = budgets.fold(0, (sum, b) => sum + b.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BudgetFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: _sorted.isEmpty
          ? _emptyState(context)
          : Column(
              children: [
                _BudgetHeader(total: totalBudget),
                Expanded(
                  child: _buildList(context, categories),
                ),
              ],
            ),
    );
  }

  Widget _buildList(BuildContext context, List<Category> categories) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: _sorted.length,
      onReorder: _onReorder,
      itemBuilder: (_, i) {
        final budget = _sorted[i];
        final category = categories.firstWhereOrNull(
          (c) => c.id == budget.categoryId,
        );
        return _BudgetCard(
          key: ValueKey(budget.id),
          budget: budget,
          category: category,
          dragHandle: ReorderableDragStartListener(
            index: i,
            child: Icon(
              Icons.dehaze,
              size: 26,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BudgetFormPage(budget: budget),
              ),
            );
          },
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    final item = _sorted.removeAt(oldIndex);
    _sorted.insert(newIndex, item);

    for (int i = 0; i < _sorted.length; i++) {
      _sorted[i].order = i;
    }

    for (final b in _sorted) {
      ref.read(budgetProvider.notifier).update(b);
    }
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first budget',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  final int total;

  const _BudgetHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      color: context.colors.surfaceContainerLow,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            formatRupiah(total),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;
  final VoidCallback onTap;
  final Widget dragHandle;

  const _BudgetCard({
    super.key,
    required this.budget,
    required this.category,
    required this.onTap,
    required this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category?.icon ?? Icons.account_balance_wallet_outlined,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _periodLabel(budget.period),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                formatRupiah(budget.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(width: 12),
              dragHandle,
            ],
          ),
        ),
      ),
    );
  }

  String _periodLabel(BudgetPeriod period) {
    return switch (period) {
      BudgetPeriod.weekly => 'Weekly',
      BudgetPeriod.monthly => 'Monthly',
      BudgetPeriod.yearly => 'Yearly',
    };
  }
}
