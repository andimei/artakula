import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 20)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isIncome;

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
  });
}
