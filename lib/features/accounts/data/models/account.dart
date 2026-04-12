import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? iconCodePoint;

  @HiveField(3)
  int? order;

  Account({
    required this.id,
    required this.name,
    this.iconCodePoint,
    this.order,
  });

  factory Account.empty() {
    return Account(id: '', name: 'Unknown');
  }

  IconData get icon => IconData(
    iconCodePoint ?? Icons.account_balance_wallet.codePoint,
    fontFamily: 'MaterialIcons',
  );
}
