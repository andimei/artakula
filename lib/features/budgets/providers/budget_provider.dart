import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/budget.dart';

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, List<Budget>>(
  (ref) => BudgetNotifier(),
);

class BudgetNotifier extends StateNotifier<List<Budget>> {
  late final Box<Budget> _box;

  BudgetNotifier() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Budget>(HiveBoxes.budgets);
    state = _box.values.toList();
    _box.listenable().addListener(_onHiveChanged);
  }

  void _onHiveChanged() {
    state = _box.values.toList();
  }

  @override
  void dispose() {
    _box.listenable().removeListener(_onHiveChanged);
    super.dispose();
  }

  Future<void> add(Budget budget) async {
    int nextOrder = 0;
    if (_box.isNotEmpty) {
      final maxOrder = _box.values
          .map((b) => b.order ?? 0)
          .reduce((a, b) => a > b ? a : b);
      nextOrder = maxOrder + 1;
    }
    budget.order = nextOrder;
    await _box.put(budget.id, budget);
  }

  Future<void> update(Budget budget) async {
    await budget.save();
  }

  Future<void> delete(Budget budget) async {
    await budget.delete();
  }
}
