import 'package:artakula/core/theme/theme_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/category_provider.dart';

/// Shows a multi-select category picker bottom sheet.
///
/// Returns a [Set<String>] of selected category IDs, or `null` if cancelled.
Future<Set<String>?> showCategoryMultiPicker({
  required BuildContext context,
  Set<String>? initialSelectedIds,
  bool? filterIncome,
  String title = 'Select Categories',
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CategoryMultiPickerSheet(
      initialSelectedIds: initialSelectedIds ?? {},
      filterIncome: filterIncome,
      title: title,
    ),
  );
}

class _CategoryMultiPickerSheet extends ConsumerStatefulWidget {
  final Set<String> initialSelectedIds;
  final bool? filterIncome;
  final String title;

  const _CategoryMultiPickerSheet({
    required this.initialSelectedIds,
    this.filterIncome,
    required this.title,
  });

  @override
  ConsumerState<_CategoryMultiPickerSheet> createState() =>
      _CategoryMultiPickerSheetState();
}

class _CategoryMultiPickerSheetState
    extends ConsumerState<_CategoryMultiPickerSheet> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    var filtered = categories.where((c) => !c.isSystem);

    if (widget.filterIncome != null) {
      filtered = filtered.where((c) => c.isIncome == widget.filterIncome);
    }

    final sorted = filtered.toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIds = sorted
                            .map((c) => c.id)
                            .toSet();
                      });
                    },
                    child: const Text('Select All'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedIds.clear());
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// LIST
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: sorted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (_, i) {
                    final cat = sorted[i];
                    final isSelected = _selectedIds.contains(cat.id);
                    final color = cat.isIncome
                        ? context.semantic.income
                        : context.semantic.expense;

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedIds.add(cat.id);
                          } else {
                            _selectedIds.remove(cat.id);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(cat.icon, color: color, size: 20),
                      ),
                      title: Text(cat.name),
                      controlAffinity: ListTileControlAffinity.trailing,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      dense: true,
                    );
                  },
                ),
              ),

              /// DONE BUTTON
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _selectedIds),
                  child: Text('Done (${_selectedIds.length} selected)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
