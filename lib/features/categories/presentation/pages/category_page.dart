import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/presentation/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/category_provider.dart';
import '../widgets/category_tile.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'EXPENSE'),
              Tab(text: 'INCOME'),
            ],
          ),
        ),

        /// FAB
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return AnimatedBuilder(
              animation: tabController,
              builder: (_, __) {
                final isIncome = tabController.index == 1;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: FloatingActionButton(
                    key: ValueKey(isIncome),
                    backgroundColor: isIncome
                        ? Colors.green.shade400
                        : Colors.red.shade400,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _openForm(context, ref, null, isIncome);
                    },
                  ),
                );
              },
            );
          },
        ),

        /// BODY
        body: TabBarView(
          children: [
            _buildList(context, ref, categories, false),
            _buildList(context, ref, categories, true),
          ],
        ),
      ),
    );
  }

  /// LIST BUILDER
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    bool isIncome,
  ) {
    final filtered = categories
        .where((c) => !c.isSystem && c.isIncome == isIncome)
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No categories'));
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final category = filtered[index];

        return CategoryTile(
          category: category,
          onTap: () {
            _openForm(context, ref, category);
          },
        );
      },
    );
  }

  /// OPEN FORM
  void _openForm(
    BuildContext context,
    WidgetRef ref, [
    Category? category,
    bool? isIncome,
  ]) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        category: category,
        isIncome: isIncome ?? category?.isIncome ?? true,
      ),
    );
  }
}
