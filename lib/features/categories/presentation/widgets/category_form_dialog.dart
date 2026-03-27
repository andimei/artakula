import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _nameController = TextEditingController();
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();

    final cat = widget.category;
    if (cat != null) {
      _nameController.text = cat.name;
      _isIncome = cat.isIncome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Income Category'),
            value: _isIncome,
            onChanged: (val) => setState(() => _isIncome = val),
          ),
        ],
      ),
      actions: [
        if (isEdit)
    TextButton(
      onPressed: _delete,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      child: const Text('Delete'),
    ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

void _save() {
  final name = _nameController.text.trim();
  if (name.isEmpty) return;

  final notifier = ref.read(categoryProvider.notifier);

  if (widget.category == null) {
    // ADD
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      isIncome: _isIncome,
    );

    notifier.add(category);
  } else {
    // UPDATE
    final category = widget.category!;

    category.name = name;
    category.isIncome = _isIncome;

    notifier.update(category);
  }

  Navigator.pop(context);
}

  void _delete() {
  final category = widget.category;
  if (category == null) return;

  final notifier = ref.read(categoryProvider.notifier);
  notifier.delete(category);

  Navigator.pop(context);
}
}
