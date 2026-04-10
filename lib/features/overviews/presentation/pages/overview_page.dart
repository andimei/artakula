import 'package:artakula/features/overviews/presentation/widgets/account_card.dart';
import 'package:artakula/features/overviews/presentation/widgets/cashflow_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overviews"),
      ),
      // body: AccountSnapshotSection(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AccountSnapshotCard(),
           SizedBox(height: 16),
          CashFlowTrendCard(),
          // SizedBox(height: 16),
          // CashFlowTrendCard(),
        ],
      ),
    );
  }
}
