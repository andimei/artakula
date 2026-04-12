import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// ================= MODEL =================
final _dateFormat = DateFormat('d MMM', 'id_ID');

String formatDayLabel(DateTime date) {
  final today = DateTime.now();

  if (_isSameDay(date, today)) {
    return "Today";
  }

  if (_isYesterday(date)) {
    return "Yesterday";
  }

  return _dateFormat.format(date);
}

class CashFlowDay {
  final DateTime date;
  double income;
  double expense;

  CashFlowDay({
    required this.date,
    this.income = 0,
    this.expense = 0,
  });
  double get net => income - expense;
}

DateTime normalize(DateTime d) {
  return DateTime(d.year, d.month, d.day);
}

/// normalize date → IMPORTANT
DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

/// ================= PROVIDER =================

final cashFlow30DaysProvider = Provider<List<CashFlowDay>>((ref) {
  final txs = ref.watch(transactionProvider);

  final now = DateTime.now();
  // final start = now.subtract(const Duration(days: 29));

  final start = normalize(
    now.subtract(const Duration(days: 29)),
  );

  final map = <DateTime, CashFlowDay>{};

  /// create 30 fixed days
  for (int i = 0; i < 30; i++) {
    final day = _dayKey(start.add(Duration(days: i)));
    map[day] = CashFlowDay(date: day);
  }

  /// fill transactions
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

    return Container(
      height: 320,
      padding: const EdgeInsets.only(top: 2, bottom: 8, left: 6, right: 16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cash Flow Trend",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _Chart(data)),
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

    final barData = BarChartData(
      minY: minY,
      maxY: maxY,
      baselineY: 0,

      alignment: BarChartAlignment.spaceBetween,
      groupsSpace: 4,

      borderData: FlBorderData(show: false),

      /// ONLY ONE GRID
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 1,
        horizontalInterval: (maxY - minY) / 6,
      ),

      // extraLinesData: ExtraLinesData(
      //   horizontalLines: [
      //     HorizontalLine(
      //       y: 1200,
      //       color: Colors.white,
      //       strokeWidth: 1,
      //     ),
      //   ],
      // ),
      // extraLinesData: ExtraLinesData(
      //   verticalLines: selected == null
      //       ? []
      //       : [
      //           VerticalLine(
      //             x: selected.toDouble(),
      //             color: Colors.white24,
      //             strokeWidth: 2,
      //             dashArray: [4, 4],
      //           ),
      //         ],
      // ),
      extraLinesData: ExtraLinesData(
        extraLinesOnTop: false,
        verticalLines: [
          VerticalLine(
            x: 10.5,
            color: Colors.white,
            strokeWidth: 4,
            dashArray: [4, 4],
            label: VerticalLineLabel(
              show: true,
            ),
          ),
        ],
        horizontalLines: [
          HorizontalLine(
            y: 0,
            color: Colors.white,
            strokeWidth: 0.5,
            // dashArray: [4, 4],
          ),
        ],
      ),

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            maxIncluded: false,
            minIncluded: false,
            showTitles: true,
            reservedSize: 26,
            interval: (maxY - minY) / 6,
            getTitlesWidget: (value, meta) {
              return _yTitle(value);
            },
          ),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 32,
            getTitlesWidget: (value, meta) => _xTitle(value, meta, data),
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

              /// toggle logic
              if (current == tappedIndex) {
                notifier.state = null; // hide tooltip
              } else {
                notifier.state = tappedIndex;
              }
            } else {
              /// tap kosong
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
              textAlign: TextAlign.end,

              children: [
                TextSpan(
                  text: "${formatDayLabel(d.date)}\n",
                  style: const TextStyle(color: Colors.white70),
                ),

                TextSpan(
                  text: "${formatValue(d.income)}\n",
                  style: const TextStyle(color: Colors.green),
                ),

                TextSpan(
                  text: "${formatValue(-d.expense)}\n",
                  style: const TextStyle(color: Colors.red),
                ),

                TextSpan(
                  text: "${d.net.toInt()}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),

        // touchTooltipData: BarTouchTooltipData(
        //   // tooltipBgColor: const Color(0xFF111827),
        //   // tooltipRoundedRadius: 14,
        //   tooltipPadding: const EdgeInsets.all(12),
        //   getTooltipItem: (group, groupIndex, rod, rodIndex) {
        //     final d = data[group.x.toInt()];

        //     return BarTooltipItem(
        //       "${d.date.day}/${d.date.month}\n"
        //       "+${d.income.toInt()}\n"
        //       "-${d.expense.toInt()}\n"
        //       "${d.net.toInt()}",
        //       const TextStyle(color: Colors.white),
        //     );
        //   },
        // ),
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
              width: 7.2,
              borderRadius: BorderRadius.zero,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                fromY: minY,
                toY: maxY,
                color: Colors.grey.withAlpha(30),
              ),
              rodStackItems: [
                /// expense (bawah)
                BarChartRodStackItem(
                  -d.expense,
                  0,
                  Colors.red,
                ),

                /// income (atas)
                BarChartRodStackItem(
                  0,
                  d.income,
                  Colors.green,
                ),
              ],
            ),
          ],
        );
      }),
    );

    return Stack(
      children: [
        BarChart(barData),

        // /// CUMULATIVE LINE
        // IgnorePointer(
        //   child: LineChart(
        //     LineChartData(
        //       minX: 0,
        //       maxX: data.length.toDouble(),
        //       minY: -maxY,
        //       maxY: maxY,
        //       borderData: FlBorderData(show: false),
        //       gridData: FlGridData(show: false),
        //       // titlesData: FlTitlesData(show: false),
        //       titlesData: FlTitlesData(
        //         leftTitles: AxisTitles(
        //           sideTitles: SideTitles(
        //             showTitles: true,
        //             reservedSize: 42,
        //             interval: maxY / 4,
        //             getTitlesWidget: (value, meta) {
        //               return _yTitle(value);
        //             },
        //           ),
        //         ),
        //         rightTitles: AxisTitles(
        //           sideTitles: SideTitles(showTitles: false),
        //         ),

        //         topTitles: AxisTitles(
        //           sideTitles: SideTitles(showTitles: false),
        //         ),

        //         bottomTitles: AxisTitles(
        //           sideTitles: SideTitles(showTitles: false),
        //         ),
        //       ),
        //       lineBarsData: [cumulativeLine(data)],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

String formatValue(double value) {
  if (value == 0) return "0";
  if (value > 0) return "+${value.toInt()}";
  return value.toInt().toString(); // sudah minus otomatis
}

Widget _yTitle(double value) {
  String text;

  if (value.abs() >= 1000000) {
    text = "${(value / 1000000).toStringAsFixed(0)}M";
  } else if (value.abs() >= 1000) {
    text = "${(value / 1000).toStringAsFixed(0)}k";
  } else {
    text = value.toInt().toString();
  }

  return SizedBox(
    width: 26,
    child: Padding(
      padding: EdgeInsets.only(right: 2),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(color: Colors.white70, fontSize: 10),
      ),
    ),
  );
}

Widget _xTitle(
  double value,
  TitleMeta meta,
  List<CashFlowDay> data,
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
    // final dateFormat = DateFormat('d MMM', 'id_ID');
    text = formatDayLabel(date);
    // text = "${date.day} ${_monthShort(date.month)}";
  }

  return SideTitleWidget(
    meta: meta,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
      ),
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

String _monthShort(int m) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  return months[m];
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
    max = [
      max,
      d.income.abs(),
      // d.expense.abs(),
    ].reduce((a, b) => a > b ? a : b);
  }

  return max == 0 ? 1 : max * 1.2;
}

double _minY(List<CashFlowDay> data) {
  double max = 0;

  for (final d in data) {
    max = [
      max,
      // d.income.abs(),
      d.expense.abs(),
    ].reduce((a, b) => a > b ? a : b);
  }

  double ret = max == 0 ? 1 : max * 1.2;

  return -ret;
}
