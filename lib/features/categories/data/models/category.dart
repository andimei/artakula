import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 20)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool isIncome;

  @HiveField(3)
  bool isSystem;

  @HiveField(4)
  String? systemKey;

  @HiveField(5)
  int? iconCodePoint;

  @HiveField(6)
  bool? isDefault;

  @HiveField(7)
  int? order;

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    this.isSystem = false,
    this.systemKey,
    this.iconCodePoint,
    this.isDefault = false,
    this.order,
  });

  IconData get icon => IconData(
    iconCodePoint ?? Icons.category.codePoint,
    fontFamily: 'MaterialIcons',
  );
}
