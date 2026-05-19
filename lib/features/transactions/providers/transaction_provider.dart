import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/accounts/provider/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/transaction.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>(
      (ref) => TransactionNotifier(),
    );

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  late final Box<Transaction> _box;

  TransactionNotifier() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Transaction>(HiveBoxes.transactions);
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

  Future<void> add(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> update(Transaction transaction) async {
    await transaction.save();
  }

  Future<void> delete(Transaction transaction) async {
    await transaction.delete();
  }

  // Delete with undo
  void deleteWithUndo(BuildContext context, Transaction tx) {
    delete(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            add(tx);
          },
        ),
      ),
    );
  }
}

final filteredTransactionProvider =
    Provider.family<List<Transaction>, DateTime>((ref, month) {
  final txs = ref.watch(transactionProvider);

  return txs.where((tx) {
    return tx.date.year == month.year &&
        tx.date.month == month.month;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});


final totalIncomeProvider =
    Provider.family<int, DateTime>((ref, month) {
  final txs = ref.watch(filteredTransactionProvider(month));

  return txs
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, tx) => sum + tx.amount);
});


final totalExpenseProvider =
    Provider.family<int, DateTime>((ref, month) {
  final txs = ref.watch(filteredTransactionProvider(month));

  return txs
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, tx) => sum + tx.amount);
});

final balanceProvider =
    Provider.family<int, DateTime>((ref, month) {
  final txs = ref.watch(filteredTransactionProvider(month));

  return txs.fold(0, (sum, tx) => sum + tx.signedAmount);
});


final accountBalanceProvider = Provider.family<int, String>((ref, accountId) {
  final txs = ref.watch(transactionProvider);

  int balance = 0;

  for (final tx in txs) {
    if (tx.type == TransactionType.income && tx.fromAccountId == accountId) {
      balance += tx.amount;
    }

    if (tx.type == TransactionType.expense && tx.fromAccountId == accountId) {
      balance -= tx.amount;
    }

    if (tx.type == TransactionType.transfer) {
      if (tx.fromAccountId == accountId) {
        balance -= tx.amount;
      }
      if (tx.toAccountId == accountId) {
        balance += tx.amount;
      }
    }
  }

  return balance;
});

final totalBalanceProvider = Provider<int>((ref) {
  final accounts = ref.watch(accountProvider);
  int total = 0;

  for (final account in accounts) {
    final balance = ref.watch(accountBalanceProvider(account.id));

    total += balance;
  }

  return total;
});
