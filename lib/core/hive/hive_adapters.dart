import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/expenses/data/models/expense.dart';

Future<void> registerHiveAdapters() async {
  await Hive.initFlutter();

  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryAdapter());

  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');
}
