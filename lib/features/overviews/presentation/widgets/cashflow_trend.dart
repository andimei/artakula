import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:artakula/shared/widgets/section_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// ================= MODEL =================
final _dateFormat = DateFormat('d MMM', 'id_ID');

String formatDayLabel(DateTime date) {
  final today = DateTime.now();
  if (_isSameDay(date, today)) return "Today";
  if (_isYesterday(date)) return "Yesterday";
  return _dateFormat.format(date);
}

class CashFlowDay {
  final DateTime date;
  double income;
  double expense;

  CashFlowDay({required this.date, this.income = 0, this.expense = 0});
  double get net => income - expense;
}

DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

/// ================= PROVIDER =================
final cashFlow30DaysProvider = Provider<List<CashFlowDay>>((ref) {
  final txs = ref.watch(transactionProvider);
  final now = DateTime.now();
  final start = normalize(now.subtract(const Duration(days: 29)));
  final map = <DateTime, CashFlowDay>{};

  for (int i = 0; i < 30; i++) {
    final day = _dayKey(start.add(Duration(days: i)));
    map[day] = CashFlowDay(date: day);
  }

  for (final tx in txs) {
    final key = _dayKey(tx.date);
    if (!map.containsKey(key)) continue;
    if (tx.type == TransactionType.income) {
      map[key]!.income += tx.amount;
    } else {
      map[key]!.expense += tx.amount;
    }
  }

  return map.values.toList();
});

/// ================= CARD =================
class CashFlowTrendCard extends ConsumerWidget {
  const CashFlowTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(cashFlow30DaysProvider);
    final cs = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Cash Flow Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: SizedBox(height: 240, child: _Chart(data)),
          ),
        ],
      ),
    );
  }
}

/// ================= CHART =================
class _Chart extends ConsumerWidget {
  final List<CashFlowDay> data;
  final selectedDayProvider = StateProvider<int?>((ref) => null);
  _Chart(this.data);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDayProvider);
    final maxY = _maxY(data);
    final minY = _minY(data);
    final cs = Theme.of(context).colorScheme;
    final semantic = context.semantic;

    final barData = BarChartData(
      minY: minY,
      maxY: maxY,
      baselineY: 0,
      alignment: BarChartAlignment.spaceBetween,
      groupsSpace: 4,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 6,
        getDrawingHorizontalLine: (value) => FlLine(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      ),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        verticalLines: [
          VerticalLine(
            x: 10.5,
            color: cs.onSurface.withValues(alpha: 0.15),
            strokeWidth: 2,
            dashArray: [4, 4],
          ),
        ],
        horizontalLines: [
          HorizontalLine(
            y: 0,
            color: cs.outlineVariant.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ],
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: (maxY - minY) / 6,
            getTitlesWidget: (value, meta) => _yTitle(value, cs),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 28,
            getTitlesWidget: (value, meta) => _xTitle(value, meta, data, cs),
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        allowTouchBarBackDraw: true,
        touchCallback: (event, response) {
          if (event is FlTapUpEvent) {
            final notifier = ref.read(selectedDayProvider.notifier);
            if (response?.spot != null) {
              final tappedIndex = response!.spot!.touchedBarGroupIndex;
              final current = ref.read(selectedDayProvider);
              if (current == tappedIndex) {
                notifier.state = null;
              } else {
                notifier.state = tappedIndex;
              }
            } else {
              notifier.state = null;
            }
          }
        },
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final d = data[group.x.toInt()];
            return BarTooltipItem(
              "",
              const TextStyle(),
              textAlign: TextAlign.center,
              children: [
                TextSpan(
                  text: "${formatDayLabel(d.date)}\n",
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                TextSpan(
                  text: "${formatValue(d.income)}\n",
                  style: TextStyle(
                    color: semantic.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: "${formatValue(-d.expense)}\n",
                  style: TextStyle(
                    color: semantic.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: "${d.net.toInt()}",
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      barGroups: List.generate(data.length, (i) {
        final d = data[i];
        return BarChartGroupData(
          x: i,
          barsSpace: 2,
          showingTooltipIndicators: selected == i ? [0] : [],
          barRods: [
            BarChartRodData(
              fromY: -d.expense,
              toY: d.income,
              width: 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                fromY: minY,
                toY: maxY,
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              rodStackItems: [
                BarChartRodStackItem(-d.expense, 0, semantic.expense),
                BarChartRodStackItem(0, d.income, semantic.income),
              ],
            ),
          ],
        );
      }),
    );

    return BarChart(barData);
  }
}

/// ================= UTILITY =================
String formatValue(double value) {
  if (value == 0) return "0";
  if (value > 0) return "+${value.toInt()}";
  return value.toInt().toString();
}

Widget _yTitle(double value, ColorScheme cs) {
  String text;
  if (value.abs() >= 1000000) {
    text = "${(value / 1000000).toStringAsFixed(0)}M";
  } else if (value.abs() >= 1000) {
    text = "${(value / 1000).toStringAsFixed(0)}k";
  } else {
    text = value.toInt().toString();
  }

  return SizedBox(
    width: 32,
    child: Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
      ),
    ),
  );
}

Widget _xTitle(
  double value,
  TitleMeta meta,
  List<CashFlowDay> data,
  ColorScheme cs,
) {
  final index = value.toInt();
  if (index % 10 != 0 && index != data.length - 1) {
    return const SizedBox();
  }
  if (index < 0 || index >= data.length) {
    return const SizedBox();
  }

  final date = data[index].date;
  final today = DateTime.now();
  String text;
  if (_isSameDay(date, today)) {
    text = "Today";
  } else {
    text = formatDayLabel(date);
  }

  return SideTitleWidget(
    meta: meta,
    child: Text(
      text,
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
    ),
  );
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return _isSameDay(date, yesterday);
}

/// ================= LINE =================
LineChartBarData cumulativeLine(List<CashFlowDay> data) {
  double sum = 0;
  final spots = <FlSpot>[];
  for (int i = 0; i < data.length; i++) {
    sum += data[i].net;
    spots.add(FlSpot(i + 0.5, sum));
  }

  return LineChartBarData(
    spots: spots,
    isCurved: true,
    preventCurveOverShooting: true,
    isStrokeCapRound: true,
    barWidth: 1.5,
    color: Colors.white.withAlpha(220),
    dotData: FlDotData(show: false),
    isStrokeJoinRound: true,
  );
}

/// ================= SCALE =================
double _maxY(List<CashFlowDay> data) {
  double max = 0;
  for (final d in data) {
    max = [max, d.income.abs()].reduce((a, b) => a > b ? a : b);
  }
  return max == 0 ? 1.0 : max * 1.2;
}

double _minY(List<CashFlowDay> data) {
  double max = 0;
  for (final d in data) {
    max = [max, d.expense.abs()].reduce((a, b) => a > b ? a : b);
  }
  final ret = max == 0 ? 1.0 : max * 1.2;
  return -ret;
}
