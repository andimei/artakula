import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/overviews/providers/category_summary_provider.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
import 'package:artakula/shared/widgets/section_card.dart';
import 'package:artakula/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategorySummaryCard extends ConsumerStatefulWidget {
  const CategorySummaryCard({super.key});

  @override
  ConsumerState<CategorySummaryCard> createState() =>
      _CategorySummaryCardState();
}

class _CategorySummaryCardState extends ConsumerState<CategorySummaryCard> {
  final _dateFormat = DateFormat('d MMM', 'id_ID');
  final _monthFormat = DateFormat('MMMM yyyy', 'id_ID');

  void _setType(TimeRangeType type) {
    ref.read(timeRangeFilterProvider.notifier).state = ref
        .read(timeRangeFilterProvider)
        .copyWith(type: type);
  }

  Future<void> _showMonthPicker() async {
    final filter = ref.read(timeRangeFilterProvider);
    final now = DateTime.now();

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initialYear: filter.selectedDate?.year ?? now.year,
        initialMonth: filter.selectedDate?.month ?? now.month,
      ),
    );

    if (picked != null && mounted) {
      ref.read(timeRangeFilterProvider.notifier).state = filter.copyWith(
        selectedDate: DateTime(picked.year, picked.month),
      );
    }
  }

  Future<void> _pickDateRange() async {
    final filter = ref.read(timeRangeFilterProvider);
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: filter.startDate != null && filter.endDate != null
          ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
          : null,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime.now(),
    );
    if (range != null && mounted) {
      ref.read(timeRangeFilterProvider.notifier).state = filter.copyWith(
        startDate: range.start,
        endDate: range.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(categorySummaryProvider);
    final filter = ref.watch(timeRangeFilterProvider);
    final cs = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.pie_chart_rounded,
            title: 'Spending by Category',
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TimeChip(
                    label: 'Today',
                    selected: filter.type == TimeRangeType.today,
                    onTap: () => _setType(TimeRangeType.today),
                  ),
                  const SizedBox(width: 8),
                  _TimeChip(
                    label: 'Week',
                    selected: filter.type == TimeRangeType.last7Days,
                    onTap: () => _setType(TimeRangeType.last7Days),
                  ),
                  const SizedBox(width: 8),
                  _TimeChip(
                    label: 'Month',
                    selected: filter.type == TimeRangeType.month,
                    onTap: () => _setType(TimeRangeType.month),
                  ),
                  const SizedBox(width: 8),
                  _TimeChip(
                    label: 'Custom',
                    selected: filter.type == TimeRangeType.dateRange,
                    onTap: () => _setType(TimeRangeType.dateRange),
                  ),
                ],
              ),
            ),
          ),
          if (filter.type == TimeRangeType.month)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextButton.icon(
                onPressed: _showMonthPicker,
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: Text(
                  _monthFormat.format(filter.selectedDate ?? DateTime.now()),
                ),
              ),
            ),
          if (filter.type == TimeRangeType.dateRange)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TextButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range_rounded, size: 16),
                label: Text(
                  filter.startDate != null && filter.endDate != null
                      ? '${_dateFormat.format(filter.startDate!)} - ${_dateFormat.format(filter.endDate!)}'
                      : 'Select date range',
                ),
              ),
            ),
          const SizedBox(height: 4),
          if (summaries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No transactions in this period',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (int i = 0; i < summaries.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              _CategoryRow(summary: summaries[i]),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            _TotalRow(summaries: summaries),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      selectedColor: cs.secondaryContainer,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategorySummary summary;
  const _CategoryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasIncome = summary.totalIncome > 0;
    final hasExpense = summary.totalExpense > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: summary.category.isIncome
                  ? context.semantic.income.withValues(alpha: 0.12)
                  : context.semantic.expense.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              summary.category.icon,
              size: 18,
              color: summary.category.isIncome
                  ? context.semantic.income
                  : context.semantic.expense,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary.category.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (hasIncome)
            Padding(
              padding: EdgeInsets.only(right: hasExpense ? 12 : 0),
              child: Text(
                '+${formatRupiah(summary.totalIncome)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.semantic.income,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          if (hasExpense)
            Text(
              '-${formatRupiah(summary.totalExpense)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.semantic.expense,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final List<CategorySummary> summaries;
  const _TotalRow({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final totalIncome = summaries.fold(0, (sum, s) => sum + s.totalIncome);
    final totalExpense = summaries.fold(0, (sum, s) => sum + s.totalExpense);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.arrow_upward_rounded,
            size: 14,
            color: context.semantic.income,
          ),
          const SizedBox(width: 4),
          Text(
            formatRupiah(totalIncome),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.semantic.income,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.arrow_downward_rounded,
            size: 14,
            color: context.semantic.expense,
          ),
          const SizedBox(width: 4),
          Text(
            formatRupiah(totalExpense),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.semantic.expense,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const _MonthPickerDialog({
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return AlertDialog(
      title: const Text('Select Month'),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _year > 2020
                      ? () => setState(() => _year--)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _year.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _year < now.year
                      ? () => setState(() => _year++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: List.generate(12, (i) {
                final month = i + 1;
                final isSelected =
                    _year == widget.initialYear && month == widget.initialMonth;
                final canSelect =
                    _year < now.year ||
                    (_year == now.year && month <= now.month);

                return FilledButton(
                  onPressed: canSelect
                      ? () => Navigator.pop(context, DateTime(_year, month))
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: isSelected
                        ? cs.primary
                        : cs.surfaceContainerHighest,
                    foregroundColor: isSelected ? cs.onPrimary : cs.onSurface,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _monthNames[i],
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
