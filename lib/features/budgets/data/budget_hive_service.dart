import 'package:hive_flutter/hive_flutter.dart';
import 'models/budget.dart';

class BudgetHiveService {
  Box<Budget> get _box => Hive.box<Budget>('budgets');

  List<Budget> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Budget budget) async {
    await _box.add(budget);
  }

  Future<void> update(Budget budget) async {
    await budget.save();
  }

  Future<void> delete(Budget budget) async {
    await budget.delete();
  }
}
