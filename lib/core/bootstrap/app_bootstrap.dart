import 'package:artakula/features/categories/data/default_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../hive/hive_adapters.dart';
import '../../features/categories/providers/category_provider.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  /// Init database
  await registerHiveAdapters();

  final notifier = ref.read(categoryProvider.notifier);

  await notifier.seedIfNeeded(defaultCategories); // seed default categrory
  await notifier.ensureSystemCategories(); // Init system data

  await notifier.seedIfNeeded(defaultCategories);

  /// Init system data
  // await ref.read(categoryProvider.notifier).ensureSystemCategories();
});
