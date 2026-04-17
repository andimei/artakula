import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/account_hive_service.dart';
import '../data/models/account.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>(
  (ref) => AccountNotifier(),
);

final sortedAccountProvider = Provider<List<Account>>((ref) {
  print("SORTED REBUILD");
  final accounts = ref.watch(accountProvider);

  final sorted = [...accounts]
    ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

  return sorted;
});

class AccountNotifier extends StateNotifier<List<Account>> {
  final _service = AccountHiveService();
  late final Box<Account> _box;

  AccountNotifier() : super([]) {
    // _load();
    _init();
  }

  void _init() {
    _box = Hive.box<Account>(HiveBoxes.accounts);

    /// load awal
    state = _box.values.toList();

    /// 🔥 AUTO LISTEN HIVE CHANGE
    _box.listenable().addListener(_onHiveChanged);
  }

  void _onHiveChanged() {
    state = _box.values.toList();
  }

  // final _service = AccountHiveService();

  // void _load() {
  //   state = _service.getAll();
  // }

  @override
  void dispose() {
    _box.listenable().removeListener(_onHiveChanged);
    super.dispose();
  }

  Future<void> add(Account account) async {
    int nextOrder = 0;

    if (_box.isNotEmpty) {
      final maxOrder = _box.values
          .map((c) => c.order ?? 0)
          .reduce((a, b) => a > b ? a : b);

      nextOrder = maxOrder + 1;
    }

    account.order = nextOrder;

    await _box.put(account.id, account);
  }

  Future<void> update(Account account) async {
    await account.save(); // listener auto trigger
  }

  Future<void> delete(Account account) async {
    await account.delete();
  }

  // Future<void> add(Account category) async {
  //   final box = Hive.box<Account>(HiveBoxes.accounts);

  //   /// cari order terakhir
  //   int nextOrder = 0;

  //   if (box.isNotEmpty) {
  //     final maxOrder = box.values
  //         .map((c) => c.order ?? 0)
  //         .reduce((a, b) => a > b ? a : b);

  //     nextOrder = maxOrder + 1;
  //   }

  //   category.order = nextOrder;

  //   await box.put(category.id, category);

  //   state = box.values.toList()
  //     ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  // }

  // Future<void> update(Account account) async {
  //   await _service.update(account);
  //   _load();
  // }

  // Future<void> delete(Account account) async {
  //   await _service.delete(account);
  //   _load();
  // }
}
