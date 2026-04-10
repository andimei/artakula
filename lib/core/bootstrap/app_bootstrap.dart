import 'package:artakula/core/bootstrap/data_migration.dart';
import 'package:artakula/features/categories/data/default_category.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../hive/hive_adapters.dart';
import '../../features/categories/providers/category_provider.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  /// Init database
  await registerHiveAdapters();

  final notifier = ref.read(categoryProvider.notifier);

  /// Seed default category (sekali saja)
  await notifier.seedIfNeeded(defaultCategories);

  /// Pastikan system category ada
  await notifier.ensureSystemCategories();
});
