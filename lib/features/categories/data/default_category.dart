import 'package:artakula/features/categories/data/models/category.dart';
import 'package:flutter/material.dart';

final defaultCategories = [
  Category(
    id: "def_food",
    name: "Makan",
    isIncome: false,
    iconCodePoint: Icons.restaurant.codePoint,
    isDefault: true,
  ),
  Category(
    id: "def_transportasi",
    name: "Transportasi",
    isIncome: false,
    iconCodePoint: Icons.directions_car.codePoint,
    isDefault: true,
  ),
  Category(
    id: "def_belanja",
    name: "Belanja",
    isIncome: false,
    iconCodePoint: Icons.shopping_bag.codePoint,
    isDefault: true,
  ),
  Category(
    id: "def_parkir",
    name: "Parkir",
    isIncome: false,
    iconCodePoint: Icons.shopping_bag.codePoint,
    isDefault: true,
  ),
  Category(
    id: "def_internet",
    name: "Internet",
    isIncome: false,
    iconCodePoint: Icons.shopping_bag.codePoint,
    isDefault: true,
  ),
];
