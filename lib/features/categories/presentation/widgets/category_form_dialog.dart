import 'package:artakula/features/categories/data/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;
  final bool isIncome;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.isIncome,
  });

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _nameController = TextEditingController();

  late bool _isIncome;
  IconData _selectedIcon = Icons.category;

  @override
  void initState() {
    super.initState();

    final cat = widget.category;

    if (cat != null) {
      /// EDIT MODE
      _nameController.text = cat.name;
      _isIncome = cat.isIncome;
      _selectedIcon = cat.icon;
    } else {
      /// ADD MODE → ikut tab aktif
      _isIncome = widget.isIncome;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Category' : 'Add Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ICON PICKER
          GestureDetector(
            onTap: _pickIcon,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _selectedIcon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// NAME
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
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

  /// SAVE
  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final notifier = ref.read(categoryProvider.notifier);

    if (widget.category == null) {
      /// ADD
      notifier.add(
        Category(
          id: const Uuid().v4(),
          name: name,
          isIncome: _isIncome,
          iconCodePoint: _selectedIcon.codePoint,
        ),
      );
    } else {
      /// UPDATE
      final category = widget.category!;

      category.name = name;
      category.isIncome = _isIncome;
      category.iconCodePoint = _selectedIcon.codePoint;

      notifier.update(category);
    }

    Navigator.pop(context);
  }

  /// DELETE
  void _delete() {
    final category = widget.category;
    if (category == null) return;

    ref.read(categoryProvider.notifier).delete(category);

    Navigator.pop(context);
  }

  /// ICON PICKER
  void _pickIcon() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categoryIcons.length,
          itemBuilder: (context, index) {
            final icon = categoryIcons[index];

            return InkWell(
              onTap: () {
                setState(() => _selectedIcon = icon);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
            );
          },
        );
      },
    );
  }
}
