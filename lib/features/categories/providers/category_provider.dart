import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/models/category.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
      return CategoryNotifier();
    });

class CategoryNotifier extends StateNotifier<List<Category>> {
  late Box<Category> _box;

  CategoryNotifier() : super([]) {
    final box = Hive.box<Category>('categories');
    _box = box;
    state = box.values.toList();
  }

  /// Add
  Future<void> add(Category category) async {
    await _box.put(category.id, category);
    state = [..._box.values];
  }

  /// Update
  Future<void> update(Category category) async {
    await category.save();
    state = [..._box.values];
  }

  /// Delete
  Future<void> delete(Category category) async {
    await category.delete();
    state = [..._box.values];
  }

  /// Refresh (optional)
  void refresh() {
    state = [..._box.values];
  }
}

final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => !c.isIncome).toList();
});

final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => c.isIncome).toList();
});

final categoriesByTypeProvider = Provider.family<List<Category>, bool>((
  ref,
  isIncome,
) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => c.isIncome == isIncome).toList();
});
