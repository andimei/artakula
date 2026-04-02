import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/transactions/data/transaction_hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>(
      (ref) => TransactionNotifier(),
    );

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    _load();
  }

  final _service = TransactionHiveService();

  void _load() {
    state = _service.getAll();
  }

  Future<void> add(Transaction transaction) async {
    await _service.add(transaction);
    _load();
  }

  Future<void> update(Transaction transaction) async {
    await _service.update(transaction);
    _load();
  }

  Future<void> delete(Transaction transaction) async {
    await _service.delete(transaction);
    _load();
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
