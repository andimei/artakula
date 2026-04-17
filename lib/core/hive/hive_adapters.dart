import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> registerHiveAdapters() async {
  await Hive.initFlutter();

  /// REGISTER ADAPTERS
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AccountAdapter());
  }

  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(CategoryAdapter());
  }

  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }

  /// OPEN BOX (safe)
  await _openBox<Account>(HiveBoxes.accounts);
  await _openBox<Category>(HiveBoxes.categories);
  await _openBox<Transaction>(HiveBoxes.transactions);

  // await migrateCategoryOrder(HiveBoxes.categoryBox);
}

Future<Box<T>> _openBox<T>(String name) async {
  if (!Hive.isBoxOpen(name)) {
    return await Hive.openBox<T>(name);
  }

  return Hive.box<T>(name);
}
