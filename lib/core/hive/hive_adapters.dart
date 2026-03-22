import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../features/expenses/data/models/expense.dart';

Future<void> registerHiveAdapters() async {
  await Hive.initFlutter();

  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Expense>('expenses');
}
