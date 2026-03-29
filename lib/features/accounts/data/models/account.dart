import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int initialBalance;

  Account({
    required this.id,
    required this.name,
    this.initialBalance = 0,
  });

  factory Account.empty() {
    return Account(id: '', name: 'Unknown');
  }
}
