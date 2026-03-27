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

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    this.isSystem = false,
    this.systemKey,
  });
}
