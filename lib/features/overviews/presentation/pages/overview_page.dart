import 'package:artakula/features/overviews/presentation/widgets/account_card.dart';
import 'package:artakula/features/overviews/presentation/widgets/budget_overview_card.dart';
import 'package:artakula/features/overviews/presentation/widgets/cashflow_trend.dart';
import 'package:artakula/features/overviews/presentation/widgets/category_pie_chart.dart';
import 'package:artakula/features/overviews/presentation/widgets/category_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          AccountSnapshotCard(),
          SizedBox(height: 16),
          CashFlowTrendCard(),
          SizedBox(height: 16),
          BudgetOverviewCard(),
          SizedBox(height: 16),
          CategorySummaryCard(),
          SizedBox(height: 16),
          CategoryPieChartCard(),
        ],
      ),
    );
  }
}
