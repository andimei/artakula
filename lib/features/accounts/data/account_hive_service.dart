import 'package:hive_flutter/hive_flutter.dart';
import 'models/account.dart';

class AccountHiveService {
  static const _boxName = 'accounts';

  Box<Account> get _box => Hive.box<Account>(_boxName);

  List<Account> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Account account) async {
    await _box.add(account);
  }

  Future<void> update(Account account) async {
    await account.save();
  }

  Future<void> delete(Account account) async {
    await account.delete();
  }
}
