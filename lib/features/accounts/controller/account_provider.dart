import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> add(Account account) async {
    await _service.add(account);
    _load();
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
