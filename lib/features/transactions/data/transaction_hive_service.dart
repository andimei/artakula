import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction.dart';

class TransactionHiveService {
  static const _boxName = 'transactions';

  Box<Transaction> get _box => Hive.box<Transaction>(_boxName);

  List<Transaction> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Transaction transaction) async {
    await _box.add(transaction);
  }

  Future<void> update(Transaction transaction) async {
    await transaction.save();
  }

  Future<void> delete(Transaction transaction) async {
    await transaction.delete();
  }
}
