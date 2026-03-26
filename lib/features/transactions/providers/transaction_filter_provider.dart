import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';


enum TransactionFilter {
  all,
  today,
  thisMonth,
}

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.all;
});

final filteredTransactionProvider = Provider((ref) {
  final txs = ref.watch(transactionProvider);
  final filter = ref.watch(transactionFilterProvider);

  final now = DateTime.now();

  switch (filter) {
    case TransactionFilter.today:
      return txs.where((tx) {
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      }).toList();

    case TransactionFilter.thisMonth:
      return txs.where((tx) {
        return tx.date.year == now.year && tx.date.month == now.month;
      }).toList();

    case TransactionFilter.all:
      return txs;
  }
});
