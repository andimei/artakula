import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/account_hive_service.dart';
import '../data/models/account.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>(
  (ref) => AccountNotifier(),
);

class AccountNotifier extends StateNotifier<List<Account>> {
  AccountNotifier() : super([]) {
    _load();
  }

  final _service = AccountHiveService();

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(Account category) async {
    final box = Hive.box<Account>(HiveBoxes.accounts);

    /// cari order terakhir
    int nextOrder = 0;

    if (box.isNotEmpty) {
      final maxOrder = box.values
          .map((c) => c.order ?? 0)
          .reduce((a, b) => a > b ? a : b);

      nextOrder = maxOrder + 1;
    }

    category.order = nextOrder;

    await box.put(category.id, category);

    state = box.values.toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  }

  Future<void> update(Account account) async {
    await _service.update(account);
    _load();
  }

  Future<void> delete(Account account) async {
    await _service.delete(account);
    _load();
  }
}
