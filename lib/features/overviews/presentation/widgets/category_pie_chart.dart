import 'package:artakula/features/overviews/providers/category_summary_provider.dart';
import 'package:artakula/shared/utils/currency_formatter.dart';
import 'package:artakula/shared/widgets/section_card.dart';
import 'package:artakula/shared/widgets/section_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pieColors = [
  Color(0xFF4CAF50),
  Color(0xFFF44336),
  Color(0xFF2196F3),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFE91E63),
  Color(0xFF3F51B5),
  Color(0xFFFF5722),
  Color(0xFF009688),
];

class CategoryPieChartCard extends ConsumerStatefulWidget {
  const CategoryPieChartCard({super.key});

  @override
  ConsumerState<CategoryPieChartCard> createState() =>
      _CategoryPieChartCardState();
}

class _CategoryPieChartCardState extends ConsumerState<CategoryPieChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(categorySummaryProvider);

    final expenseData = summaries.where((s) => s.totalExpense > 0).toList();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.pie_chart_rounded,
            title: 'Expense Distribution',
          ),
          if (expenseData.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'No expenses in this period',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            )
          else ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Center(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = null;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: _buildSections(expenseData),
                    centerSpaceRadius: 50,
                    sectionsSpace: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...expenseData.asMap().entries.map(
              (entry) => _LegendRow(
                index: entry.key,
                summary: entry.value,
                totalExpense: expenseData.fold(
                  0,
                  (sum, s) => sum + s.totalExpense,
                ),
                isSelected: _touchedIndex == entry.key,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<CategorySummary> data) {
    final total = data.fold<int>(0, (sum, s) => sum + s.totalExpense);

    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final isSelected = _touchedIndex == i;
      final percentage = (s.totalExpense / total * 100);

      return PieChartSectionData(
        color: _pieColors[i % _pieColors.length],
        value: s.totalExpense.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isSelected ? 65 : 55,
        titleStyle: TextStyle(
          fontSize: isSelected ? 13 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}

class _LegendRow extends StatelessWidget {
  final int index;
  final CategorySummary summary;
  final int totalExpense;
  final bool isSelected;

  const _LegendRow({
    required this.index,
    required this.summary,
    required this.totalExpense,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = (summary.totalExpense / totalExpense * 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _pieColors[index % _pieColors.length],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summary.category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatRupiah(summary.totalExpense),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: cs.onSurface,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
