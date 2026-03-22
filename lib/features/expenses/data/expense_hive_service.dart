import 'package:hive/hive.dart';
import 'models/expense.dart';

class ExpenseHiveService {
  final _box = Hive.box<Expense>('expenses');

  List<Expense> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Expense expense) async {
    await _box.add(expense);
  }

  Future<void> delete(Expense expense) async {
    await expense.delete();
  }

  Future<void> update(Expense expense) async {
    await expense.save();
  }

  Future<void> putAt(int index, Expense expense) async {
    await _box.put(index, expense);
  }
}
