import 'package:artakula/features/categories/presentation/widgets/category_form_dialog.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../data/models/category.dart';
// import '../../providers/category_provider.dart';
import '../../../categories/providers/category_provider.dart';
// import '../../../transactions/domain/transaction_type.dart';

class CategoryPickerPage extends ConsumerWidget {
  final TransactionType type;
  final String? selectedId;

  const CategoryPickerPage({
    super.key,
    required this.type,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    bool isIncome = TransactionType.income == type;

    /// filter category sesuai type
    // final filtered = categories
    //     .where((c) => !c.isSystem)
    //     .where((c) => c.isIncome == isIncome)
    //     .toList();

    final filtered =
        categories.where((c) => !c.isSystem && c.isIncome == isIncome).toList()
          ..sort(
            (a, b) => (a.order ?? 0).compareTo(b.order ?? 0),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Category"),
        // backgroundColor: Colors.green,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref, isIncome),
        child: const Icon(Icons.add),
      ),

      body: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          color: Color.fromARGB(255, 226, 226, 226),
          indent: 18,
          endIndent: 18,
        ),
        itemBuilder: (context, index) {
          final category = filtered[index];

          final isSelected = category.id == selectedId;

          final color = category.isIncome ? Colors.green : Colors.red;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),

            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: Colors.white,
              ),
            ),

            title: Text(
              category.name,
              style: const TextStyle(fontSize: 16),
            ),

            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,

            onTap: () {
              Navigator.pop(context, category);
            },
          );
        },
      ),
    );
  }

  /// OPEN FORM
  void _openForm(
    BuildContext context,
    WidgetRef ref,
    bool isIncome,
  ) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
        isIncome: isIncome,
      ),
    );
  }
}
