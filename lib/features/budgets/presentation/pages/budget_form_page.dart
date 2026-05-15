import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/budgets/providers/budget_provider.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/categories/providers/category_provider.dart';
import 'package:artakula/features/transactions/presentation/widgets/numeric_keypad.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class BudgetFormPage extends ConsumerStatefulWidget {
  final Budget? budget;

  const BudgetFormPage({super.key, this.budget});

  @override
  ConsumerState<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends ConsumerState<BudgetFormPage> {
  final _nameController = TextEditingController();

  int _amount = 0;
  BudgetPeriod _period = BudgetPeriod.monthly;
  late DateTime _startDate;
  Category? _category;

  bool get isEdit => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    if (b != null) {
      _nameController.text = b.name;
      _amount = b.amount;
      _period = b.period;
      _startDate = b.startDate;
    } else {
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final categories = ref.watch(expenseCategoriesProvider);

    if (_category != null && widget.budget == null) {
      final stillExists = categories.any((c) => c.id == _category!.id);
      if (!stillExists) _category = null;
    }

    if (widget.budget != null && _category == null) {
      _category = categories.where(
        (c) => c.id == widget.budget!.categoryId,
      ).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Budget' : 'New Budget'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _nameField(),
                const SizedBox(height: 16),
                _categoryPicker(context, categories),
                const SizedBox(height: 16),
                _periodPicker(),
                const SizedBox(height: 16),
                _datePicker(),
                const SizedBox(height: 24),
                _amountHero(),
              ],
            ),
          ),

          _saveButton(),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: keyboardOpen
                ? const SizedBox.shrink()
                : NumericKeypad(
                    onKeyTap: _onKeyTap,
                    onClear: _clearAmount,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Budget Name',
        hintText: 'e.g. Monthly Groceries',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: context.colors.surface,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLength: 30,
    );
  }

  Widget _categoryPicker(BuildContext context, List<Category> categories) {
    return InkWell(
      onTap: () => _pickCategory(context, categories),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (_category != null)
              CircleAvatar(
                radius: 16,
                backgroundColor: context.semantic.expense.withValues(alpha: 0.12),
                child: Icon(
                  _category!.icon,
                  size: 16,
                  color: context.semantic.expense,
                ),
              )
            else
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.surfaceContainerHighest,
                child: Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _category?.name ?? 'Select Category',
                style: TextStyle(
                  fontSize: 14,
                  color: _category != null
                      ? context.colors.onSurface
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _pickCategory(BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final selected = cat.id == _category?.id;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.semantic.expense.withValues(alpha: 0.12),
                            child: Icon(
                              cat.icon,
                              color: context.semantic.expense,
                            ),
                          ),
                          title: Text(cat.name),
                          trailing: selected
                              ? Icon(Icons.check_rounded, color: context.colors.primary)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          selected: selected,
                          onTap: () {
                            setState(() => _category = cat);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _periodPicker() {
    return SegmentedButton<BudgetPeriod>(
      segments: const [
        ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
        ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
        ButtonSegment(value: BudgetPeriod.yearly, label: Text('Yearly')),
      ],
      selected: {_period},
      onSelectionChanged: (v) => setState(() => _period = v.first),
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _datePicker() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              '${_startDate.day} ${months[_startDate.month - 1]} ${_startDate.year}',
              style: TextStyle(
                fontSize: 14,
                color: context.colors.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Widget _amountHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        formatRupiah(_amount),
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: context.colors.onSurface,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: FilledButton(
        onPressed: _save,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isEdit ? 'Update Budget' : 'Create Budget',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == "del") {
        _amount = _amount ~/ 10;
        return;
      }
      final digit = int.parse(key);
      if (_amount > 999999999) return;
      _amount = (_amount * 10) + digit;
    });
  }

  void _clearAmount() {
    setState(() => _amount = 0);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _error('Please enter a budget name');
      return;
    }
    if (_category == null) {
      _error('Please select a category');
      return;
    }
    if (_amount <= 0) {
      _error('Please set a budget amount');
      return;
    }

    final notifier = ref.read(budgetProvider.notifier);

    if (isEdit) {
      final b = widget.budget!;
      b.name = name;
      b.categoryId = _category!.id;
      b.amount = _amount;
      b.period = _period;
      b.startDate = _startDate;
      notifier.update(b);
    } else {
      notifier.add(Budget(
        id: const Uuid().v4(),
        name: name,
        categoryId: _category!.id,
        amount: _amount,
        period: _period,
        startDate: _startDate,
      ));
    }

    Navigator.pop(context);
  }

  void _error(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
