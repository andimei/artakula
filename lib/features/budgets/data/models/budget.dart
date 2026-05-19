// import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 30)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String categoryId;

  @HiveField(3)
  int amount;

  @HiveField(4)
  BudgetPeriod period;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  int? order;

  @HiveField(7)
  List<String> categoryIds;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    this.order,
    List<String>? categoryIds,
  })  : categoryIds = categoryIds ?? [],
        categoryId = (categoryIds ?? []).isEmpty ? '' : (categoryIds!.first);
}

@HiveType(typeId: 31)
enum BudgetPeriod {
  @HiveField(0)
  weekly,

  @HiveField(1)
  monthly,

  @HiveField(2)
  yearly,
}
