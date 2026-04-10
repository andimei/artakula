import 'package:artakula/core/bootstrap/data_migration.dart';
import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/expenses/data/models/expense.dart';

Future<void> registerHiveAdapters() async {
  await Hive.initFlutter();

  /// REGISTER ADAPTERS (safe)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AccountAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ExpenseAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TransactionAdapter());
  }

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }

  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(CategoryAdapter());
  }

  /// OPEN BOX (safe)
  await _openBox<Account>(HiveBoxes.accounts);
  await _openBox<Category>(HiveBoxes.categories);
  await _openBox<Transaction>(HiveBoxes.transactions);

  await migrateCategoryOrder(HiveBoxes.categoryBox);

  // await _openBox<Expense>('expenses');
  // await _openBox<Category>('categories');
}

Future<Box<T>> _openBox<T>(String name) async {
  if (!Hive.isBoxOpen(name)) {
    return await Hive.openBox<T>(name);
  }

  return Hive.box<T>(name);
}

// Future<void> registerHiveAdapters() async {
//   await Hive.initFlutter();

//   Hive.registerAdapter(AccountAdapter());
//   Hive.registerAdapter(ExpenseAdapter());
//   Hive.registerAdapter(TransactionAdapter());
//   Hive.registerAdapter(TransactionTypeAdapter());
//   Hive.registerAdapter(CategoryAdapter());

//   await Hive.openBox<Account>('accounts');
//   await Hive.openBox<Expense>('expenses');
//   await Hive.openBox<Transaction>('transactions');
//   await Hive.openBox<Category>('categories');
// }
