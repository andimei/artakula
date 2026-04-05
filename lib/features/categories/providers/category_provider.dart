import 'package:artakula/features/categories/data/category_hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/category.dart';

final categoryServiceProvider = Provider<CategoryHiveService>((ref) {
  return CategoryHiveService();
});

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
      (ref) => CategoryNotifier(
        ref.read(categoryServiceProvider),
      ),
    );

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier(this._service) : super([]) {
    _load();
  }

  final CategoryHiveService _service;

  void _load() {
    state = _service.getAll();
  }

  bool get isEmpty => _service.isEmpty;

  Future<void> seedIfNeeded(List<Category> defaults) async {
    if (!_service.isEmpty) return;

    for (final c in defaults) {
      await _service.add(c);
    }

    _load();
  }

  Future<void> add(Category category) async {
    await _service.add(category);
    _load();
  }

  Future<void> update(Category category) async {
    await _service.update(category);
    _load();
  }

  Future<void> delete(Category category) async {
    if (category.isSystem) return; // protect system category
    await _service.delete(category);
    _load();
  }

  /// SYSTEM CATEGORY CREATOR
  Future<void> ensureSystemCategories() async {
    final categories = _service.getAll();

    final exists = categories.any(
      (c) => c.systemKey == SystemCategory.initialBalance,
    );

    if (exists) return;

    await _service.add(
      Category(
        id: const Uuid().v4(),
        name: "Initial Balance",
        isIncome: true,
        isSystem: true,
        systemKey: SystemCategory.initialBalance,
        iconCodePoint: Icons.money_rounded.codePoint,
      ),
    );

    _load();
  }
}

class SystemCategory {
  static const initialBalance = "initial_balance";
}

final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => !c.isIncome && !c.isSystem).toList();
});

final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoryProvider);
  return categories.where((c) => c.isIncome && !c.isSystem).toList();
});

final categoriesByTypeProvider = Provider.family<List<Category>, bool>((
  ref,
  isIncome,
) {
  final categories = ref.watch(categoryProvider);

  return categories
      .where(
        (c) => c.isIncome == isIncome && !c.isSystem,
      )
      .toList();
});
