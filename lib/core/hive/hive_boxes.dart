import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:hive/hive.dart';

class HiveBoxes {
  static const accounts = 'accounts';
  static const transactions = 'transactions';
  static const categories = 'categories';
  static const budgets = 'budgets';

  static Box<Category> get categoryBox => Hive.box<Category>(categories);
  static Box<Budget> get budgetBox => Hive.box<Budget>(budgets);
}
