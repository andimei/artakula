import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier();
    });

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  late Box<Transaction> _box;

  TransactionNotifier() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Transaction>('transactions');
    state = _box.values.toList();
  }

  /// Add
  Future<void> add(Transaction tx) async {
    await _box.put(tx.id, tx);
    state = [...state, tx];
  }

  /// Update
  Future<void> update(Transaction tx) async {
    await tx.save();
    state = [..._box.values];
  }

  /// Delete
  Future<void> delete(Transaction tx) async {
    await tx.delete();
    state = [..._box.values];
  }

  /// Delete with undo
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

  /// Refresh manual (optional)
  void refresh() {
    state = [..._box.values];
  }
}

final totalIncomeProvider = Provider<int>((ref) {
  final txs = ref.watch(transactionProvider);

  return txs
      .where((tx) => tx.type == TransactionType.income)
      .fold(0, (sum, tx) => sum + tx.amount);
});

final totalExpenseProvider = Provider<int>((ref) {
  final txs = ref.watch(transactionProvider);

  return txs
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0, (sum, tx) => sum + tx.amount);
});

final balanceProvider = Provider<int>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);

  return income - expense;
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
