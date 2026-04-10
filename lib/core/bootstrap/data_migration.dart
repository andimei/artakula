import 'package:artakula/features/categories/data/models/category.dart';
import 'package:hive/hive.dart';

Future<void> migrateCategoryOrder(Box<Category> box) async {
  final categories = box.values.toList();

  /// cek apakah migration diperlukan (sementara tambahan order)
  final needMigration = categories.any((c) => c.order == null);

  print(needMigration);

  if (!needMigration) return;

  /// pisahkan group
  final expense = categories.where((c) => !c.isSystem && !c.isIncome).toList();

  final income = categories.where((c) => !c.isSystem && c.isIncome).toList();

  /// assign order PER GROUP
  for (int i = 0; i < expense.length; i++) {
    expense[i].order ??= i;
  }

  for (int i = 0; i < income.length; i++) {
    income[i].order ??= i;
  }

  /// save
  await box.putAll({
    for (final c in [...expense, ...income]) c.key: c,
  });
}
