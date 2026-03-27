import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../hive/hive_adapters.dart';
import '../../features/categories/providers/category_provider.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  /// Init database
  await registerHiveAdapters();

  /// Init system data
  await ref.read(categoryProvider.notifier).ensureSystemCategories();
});
