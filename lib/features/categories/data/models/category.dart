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

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    this.isSystem = false,
    this.systemKey,
    this.iconCodePoint,
    this.isDefault = false,
  });

  IconData get icon => IconData(
    // iconCodePoint ?? 0xe574, // default icon
    iconCodePoint ?? Icons.category.codePoint,
    fontFamily: 'MaterialIcons',
  );
}
