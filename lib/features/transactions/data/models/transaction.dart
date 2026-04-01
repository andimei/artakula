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

  /// ===== COPY WITH =====
  Transaction copyWith({
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? categoryId,
    String? fromAccountId,
    String? toAccountId,
    String? note,
  }) {
    return Transaction(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }

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

@HiveType(typeId: 11)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,

  @HiveField(2)
  transfer,
}

// @HiveType(typeId: 10)
// class Transaction extends HiveObject {
//   @HiveField(0)
//   String id;

//   @HiveField(1)
//   int amount;

//   @HiveField(2)
//   TransactionType type;

//   @HiveField(3)
//   DateTime date;

//   @HiveField(4)
//   String note;

//   @HiveField(5)
//   String? categoryId;

//   @HiveField(6)
//   String fromAccountId;

//   @HiveField(7)
//   String? toAccountId;

//   @HiveField(8)
//   DateTime createdAt;

//   Transaction({
//     required this.id,
//     required this.amount,
//     required this.type,
//     required this.date,
//     required this.fromAccountId,
//     this.toAccountId,
//     this.categoryId,
//     this.note = '',
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();

//     Transaction copyWith({
//     TransactionType? type,
//     int? amount,
//     DateTime? date,
//     String? categoryId,
//     String? fromAccountId,
//     String? toAccountId,
//     String? note,
//   }) {
//     return Transaction(
//       id: id,
//       type: type ?? this.type,
//       amount: amount ?? this.amount,
//       date: date ?? this.date,
//       categoryId: categoryId ?? this.categoryId,
//       fromAccountId: fromAccountId ?? this.fromAccountId,
//       toAccountId: toAccountId ?? this.toAccountId,
//       note: note ?? this.note,
//     );
//   }
// }

//   DateTime get dateOnly {
//     return DateTime(date.year, date.month, date.day);
//   }

//   int get signedAmount {
//     switch (type) {
//       case TransactionType.income:
//         return amount;

//       case TransactionType.expense:
//         return -amount;

//       case TransactionType.transfer:
//         return 0;
//     }
//   }

// }

// @HiveType(typeId: 11)
// enum TransactionType {
//   @HiveField(0)
//   income,

//   @HiveField(1)
//   expense,

//   @HiveField(2)
//   transfer,
// }
