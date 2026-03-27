import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 10)
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

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.fromAccountId,
    this.toAccountId,
    this.categoryId,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 11)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  transfer,
}
