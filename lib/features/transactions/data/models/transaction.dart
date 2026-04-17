import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 20)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int amount;

  @HiveField(2)
  TransactionType type;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String note;

  @HiveField(5)
  String? categoryId;

  @HiveField(6)
  String fromAccountId;

  @HiveField(7)
  String? toAccountId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  bool isInitialBalance;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.fromAccountId,
    this.toAccountId,
    this.categoryId,
    this.note = '',
    this.isInitialBalance = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ===== HELPERS =====

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  int get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return 0;
    }
  }
}

@HiveType(typeId: 21)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  transfer,
}

