import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/presentation/widgets/category_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/category_provider.dart';
import '../widgets/category_tile.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    // final categories = ref.watch(categoryProvider)
    //   ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

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
              builder: (_, _) {
                final isIncome = tabController.index == 1;

                return FloatingActionButton(
                  backgroundColor: isIncome
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _openForm(context, null, isIncome);
                  },
                );
              },
            );
          },
        ),

        body: TabBarView(
          children: [
            _buildList(context, categories, false),
            _buildList(context, categories, true),
          ],
        ),
      ),
    );
  }

  // ===============================
  // LIST
  // ===============================

  Widget _buildList(
    BuildContext context,
    List<Category> categories,
    bool isIncome,
  ) {
    final filtered =
        categories.where((c) => !c.isSystem && c.isIncome == isIncome).toList()
          ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    if (filtered.isEmpty) {
      return const Center(child: Text('No categories'));
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),

      itemCount: filtered.length,

      onReorder: (oldIndex, newIndex) =>
          _onReorder(filtered, oldIndex, newIndex),

      itemBuilder: (context, index) {
        final category = filtered[index];

        return CategoryTile(
          key: ValueKey(category.id),
          category: category,
          dragHandle: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.dehaze, color: Colors.grey),
          ),
          onTap: () {
            _openForm(context, category, isIncome);
          },
        );
      },
    );
  }

  // ===============================
  // REORDER LOGIC
  // ===============================

  Future<void> _onReorder(
    List<Category> list,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    /// update order hanya group ini
    for (int i = 0; i < list.length; i++) {
      list[i].order = i;
    }

    await Future.wait(list.map((c) => c.save()));

    setState(() {});
  }

  // ===============================
  // OPEN FORM
  // ===============================

  void _openForm(
    BuildContext context,
    Category? category,
    bool isIncome,
  ) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        category: category,
        isIncome: isIncome,
      ),
    );
  }
}



  // Widget _buildList(
  //   BuildContext context,
  //   WidgetRef ref,
  //   List<Category> categories,
  //   bool isIncome,
  // ) {
  //   // final filtered = categories.where((c) => c.isIncome == isIncome).toList();

  //   final filtered = categories
  //       .where((c) => !c.isSystem && c.isIncome == isIncome)
  //       .toList();

  //   if (filtered.isEmpty) {
  //     return const Center(child: Text('No categories'));
  //   }

  //   // return ListView.builder(
  //   //   padding: EdgeInsets.only(
  //   //     bottom: MediaQuery.of(context).padding.bottom + 80,
  //   //   ),
  //   //   itemCount: filtered.length,
  //   //   itemBuilder: (context, index) {
  //   //     final category = filtered[index];

  //   //     return CategoryTile(
  //   //       category: category,
  //   //       onTap: () {
  //   //         _openForm(context, ref, category);
  //   //       },
  //   //     );
  //   //   },
  //   // );

  //   return ReorderableListView.builder(
  //     itemCount: filtered.length,

  //     onReorder: _onReorder(),

  //     itemBuilder: (context, index) {
  //       final category = categories[index];

  //       return CategoryTile(
  //         key: ValueKey(category.id),
  //         category: category,
  //         onTap: () {},
  //       );
  //     },
  //   );
  // }