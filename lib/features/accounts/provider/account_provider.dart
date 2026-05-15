import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/account.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, List<Account>>(
  (ref) => AccountNotifier(),
);

final sortedAccountProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountProvider);

  final sorted = [...accounts]
    ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

  return sorted;
});

class AccountNotifier extends StateNotifier<List<Account>> {
  late final Box<Account> _box;

  AccountNotifier() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Account>(HiveBoxes.accounts);
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
    await account.save();
  }

  Future<void> delete(Account account) async {
    await account.delete();
  }
}
