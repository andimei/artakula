import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/categories/data/category_hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  late final Box<Category> _box;

  CategoryNotifier(this._service) : super([]) {
    _init();
  }

  final CategoryHiveService _service;

  void _init() {
    _box = Hive.box<Category>(HiveBoxes.categories);
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

  bool get isEmpty => _service.isEmpty;

  Future<void> seedIfNeeded(List<Category> defaults) async {
    if (!_service.isEmpty) return;

    for (final c in defaults) {
      await _service.add(c);
    }
  }

  Future<void> add(Category category) async {
    int nextOrder = 0;
    if (_box.isNotEmpty) {
      final maxOrder = _box.values
          .map((c) => c.order ?? 0)
          .reduce((a, b) => a > b ? a : b);
      nextOrder = maxOrder + 1;
    }

    category.order = nextOrder;

    await _box.put(category.id, category);
  }

  Future<void> update(Category category) async {
    await category.save();
  }

  Future<void> delete(Category category) async {
    if (category.isSystem) return; // protect system category
    await category.delete();
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
