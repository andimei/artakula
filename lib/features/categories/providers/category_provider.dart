import 'package:artakula/features/categories/data/category_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/category.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
      (ref) => CategoryNotifier(),
    );

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _init();
  }

  final _service = CategoryHiveService();

  Future<void> _init() async {
    await ensureSystemCategories();
    _load();
  }

  void _load() {
    state = _service.getAll();
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

    final existingKeys = categories.map((c) => c.systemKey).toSet();

    final List<Category> systemCategories = [];

    if (!existingKeys.contains(SystemCategory.initialBalance)) {
      systemCategories.add(
        Category(
          id: const Uuid().v4(),
          name: "Initial Balance",
          isIncome: true,
          isSystem: true,
          systemKey: SystemCategory.initialBalance,
        ),
      );
    }

    if (!existingKeys.contains(SystemCategory.adjustmentIncome)) {
      systemCategories.add(
        Category(
          id: const Uuid().v4(),
          name: "Adjustment",
          isIncome: true,
          isSystem: true,
          systemKey: SystemCategory.adjustmentIncome,
        ),
      );
    }

    if (!existingKeys.contains(SystemCategory.adjustmentExpense)) {
      systemCategories.add(
        Category(
          id: const Uuid().v4(),
          name: "Adjustment",
          isIncome: false,
          isSystem: true,
          systemKey: SystemCategory.adjustmentExpense,
        ),
      );
    }

    for (final category in systemCategories) {
      await _service.add(category);
    }

    _load(); // refresh state
  }
}

class SystemCategory {
  static const initialBalance = "initial_balance";
  static const adjustmentIncome = "adjustment_income";
  static const adjustmentExpense = "adjustment_expense";
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
