import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/budgets/providers/budget_provider.dart';
import 'package:artakula/features/categories/presentation/widgets/category_multi_picker.dart';
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
  Set<String> _selectedCategoryIds = {};

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
      _selectedCategoryIds = Set.from(b.categoryIds);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Budget' : 'New Budget'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              style: IconButton.styleFrom(
                foregroundColor: context.colors.onSurfaceVariant,
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _nameField(),
                const SizedBox(height: 16),
                _categoryPicker(context),
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

  Widget _categoryPicker(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider);
    final selected = categories.where((c) => _selectedCategoryIds.contains(c.id));

    return InkWell(
      onTap: () => _pickCategories(context),
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
            CircleAvatar(
              radius: 16,
              backgroundColor: context.semantic.expense.withValues(alpha: 0.12),
              child: Icon(
                Icons.category_outlined,
                size: 16,
                color: context.semantic.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: selected.isEmpty
                  ? Text(
                      'Select Categories',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selected.length} categories',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selected.map((c) => c.name).join(', '),
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCategories(BuildContext context) async {
    final selected = await showCategoryMultiPicker(
      context: context,
      initialSelectedIds: _selectedCategoryIds,
      filterIncome: false,
      title: 'Select Categories',
    );

    if (selected != null) {
      setState(() => _selectedCategoryIds = selected);
    }
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

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete budget?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final b = widget.budget;
      if (b == null) return;
      await ref.read(budgetProvider.notifier).delete(b);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _error('Please enter a budget name');
      return;
    }
    if (_selectedCategoryIds.isEmpty) {
      _error('Please select at least one category');
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
      b.categoryIds = _selectedCategoryIds.toList();
      b.amount = _amount;
      b.period = _period;
      b.startDate = _startDate;
      notifier.update(b);
    } else {
      notifier.add(Budget(
        id: const Uuid().v4(),
        name: name,
        categoryIds: _selectedCategoryIds.toList(),
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
