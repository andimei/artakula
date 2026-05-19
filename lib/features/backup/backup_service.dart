import 'dart:convert';
import 'dart:io';

import 'package:artakula/core/hive/hive_boxes.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/budgets/data/models/budget.dart';
import 'package:artakula/features/categories/data/models/category.dart';
import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  /// Export all data to a JSON string
  Future<String> exportToJson() async {
    final accountBox = Hive.box<Account>(HiveBoxes.accounts);
    final categoryBox = Hive.box<Category>(HiveBoxes.categories);
    final transactionBox = Hive.box<Transaction>(HiveBoxes.transactions);
    final budgetBox = Hive.box<Budget>(HiveBoxes.budgets);

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'accounts': accountBox.values.map(_accountToMap).toList(),
      'categories': categoryBox.values.map(_categoryToMap).toList(),
      'transactions': transactionBox.values.map(_transactionToMap).toList(),
      'budgets': budgetBox.values.map(_budgetToMap).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Let user pick a directory and save backup there. Returns path or null.
  Future<String?> exportToUserLocation() async {
    final json = await exportToJson();
    final now = DateTime.now();
    final ts =
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${(now.year % 100).toString().padLeft(2, '0')}';
    final fileName = 'artakula_backup_$ts.json';

    // print("test");
    if (Platform.isAndroid) {
      // print("ini adroid");
      return _pickAndSaveOnAndroid(fileName, json);
    }

    final dirPath = await getDirectoryPath(
      confirmButtonText: 'Save Here',
    );

    if (dirPath == null) return null;

    try {
      final file = File('$dirPath/$fileName');
      await file.writeAsString(json);
      return file.path;
    } catch (_) {
      // On Linux the portal path may not be directly writable.
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(json);
      return file.path;
    }
  }

  Future<String?> _pickAndSaveOnAndroid(
    String fileName,
    String content,
  ) async {
    const channel = MethodChannel('artakula/backup');
    return await channel.invokeMethod<String>('saveBackup', {
      'fileName': fileName,
      'content': content,
    });
  }

  /// Let user pick a backup file and import it. Returns path or null.
  Future<String?> pickAndImport() async {
    final xfile = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'JSON Backup',
          extensions: ['json'],
        ),
      ],
    );

    if (xfile == null) return null;

    final path = xfile.path;
    final file = File(path);
    final json = await file.readAsString();
    await importFromJson(json);
    return path;
  }

  /// Import from a JSON string (replaces all data)
  Future<void> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;

    final accountBox = Hive.box<Account>(HiveBoxes.accounts);
    final categoryBox = Hive.box<Category>(HiveBoxes.categories);
    final transactionBox = Hive.box<Transaction>(HiveBoxes.transactions);
    final budgetBox = Hive.box<Budget>(HiveBoxes.budgets);

    await accountBox.clear();
    await categoryBox.clear();
    await transactionBox.clear();
    await budgetBox.clear();

    for (final m in data['accounts'] as List) {
      await accountBox.put(m['id'], _accountFromMap(m));
    }
    for (final m in data['categories'] as List) {
      await categoryBox.put(m['id'], _categoryFromMap(m));
    }
    for (final m in data['transactions'] as List) {
      await transactionBox.put(m['id'], _transactionFromMap(m));
    }
    for (final m in data['budgets'] as List) {
      await budgetBox.put(m['id'], _budgetFromMap(m));
    }
  }

  // ─── Serializers ───

  Map<String, dynamic> _accountToMap(Account a) => {
    'id': a.id,
    'name': a.name,
    'iconCodePoint': a.iconCodePoint,
    'order': a.order,
  };

  Account _accountFromMap(Map<String, dynamic> m) => Account(
    id: m['id'] as String,
    name: m['name'] as String,
    iconCodePoint: m['iconCodePoint'] as int?,
    order: m['order'] as int?,
  );

  Map<String, dynamic> _categoryToMap(Category c) => {
    'id': c.id,
    'name': c.name,
    'isIncome': c.isIncome,
    'isSystem': c.isSystem,
    'systemKey': c.systemKey,
    'iconCodePoint': c.iconCodePoint,
    'isDefault': c.isDefault,
    'order': c.order,
  };

  Category _categoryFromMap(Map<String, dynamic> m) => Category(
    id: m['id'] as String,
    name: m['name'] as String,
    isIncome: m['isIncome'] as bool,
    isSystem: m['isSystem'] as bool? ?? false,
    systemKey: m['systemKey'] as String?,
    iconCodePoint: m['iconCodePoint'] as int?,
    isDefault: m['isDefault'] as bool? ?? false,
    order: m['order'] as int?,
  );

  Map<String, dynamic> _transactionToMap(Transaction t) => {
    'id': t.id,
    'type': t.type.name,
    'amount': t.amount,
    'date': t.date.toIso8601String(),
    'categoryId': t.categoryId,
    'fromAccountId': t.fromAccountId,
    'toAccountId': t.toAccountId,
    'note': t.note,
    'isInitialBalance': t.isInitialBalance,
  };

  Transaction _transactionFromMap(Map<String, dynamic> m) {
    return Transaction(
      id: m['id'] as String,
      type: TransactionType.values.byName(m['type'] as String),
      amount: m['amount'] as int,
      date: DateTime.parse(m['date'] as String),
      categoryId: m['categoryId'] as String?,
      fromAccountId: m['fromAccountId'] as String,
      toAccountId: m['toAccountId'] as String?,
      note: m['note'] as String? ?? '',
      isInitialBalance: m['isInitialBalance'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _budgetToMap(Budget b) => {
    'id': b.id,
    'name': b.name,
    'amount': b.amount,
    'period': b.period.name,
    'startDate': b.startDate.toIso8601String(),
    'order': b.order,
    'categoryIds': b.categoryIds,
  };

  Budget _budgetFromMap(Map<String, dynamic> m) {
    return Budget(
      id: m['id'] as String,
      name: m['name'] as String,
      amount: m['amount'] as int,
      period: BudgetPeriod.values.byName(m['period'] as String),
      startDate: DateTime.parse(m['startDate'] as String),
      order: m['order'] as int?,
      categoryIds: (m['categoryIds'] as List?)?.cast<String>() ?? [],
    );
  }
}
