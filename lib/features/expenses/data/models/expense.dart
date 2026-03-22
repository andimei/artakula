import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int amount;

  @HiveField(3)
  String account;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String note;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.account,
    required this.category,
    required this.note,
    required this.date,
  });
}
