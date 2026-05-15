import 'package:artakula/features/categories/data/models/category.dart';
import 'package:hive/hive.dart';

class HiveBoxes {
  static const accounts = 'accounts';
  static const transactions = 'transactions';
  static const categories = 'categories';

  static Box<Category> get categoryBox => Hive.box<Category>(categories);
}
