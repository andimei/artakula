import 'package:hive_flutter/hive_flutter.dart';
import 'models/category.dart';

class CategoryHiveService {
  static const _boxName = 'categories';

  Box<Category> get _box => Hive.box<Category>(_boxName);

  List<Category> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Category category) async {
    await _box.add(category);
  }

  Future<void> update(Category category) async {
    await category.save();
  }

  Future<void> delete(Category category) async {
    await category.delete();
  }

  bool get isEmpty => _box.isEmpty;
}
