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
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static const _currentBackupVersion = 1;

  /// Export all data to a JSON string
  Future<String> exportToJson() async {
    final accountBox = Hive.box<Account>(HiveBoxes.accounts);
    final categoryBox = Hive.box<Category>(HiveBoxes.categories);
    final transactionBox = Hive.box<Transaction>(HiveBoxes.transactions);
    final budgetBox = Hive.box<Budget>(HiveBoxes.budgets);

    final data = {
      'version': _currentBackupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'accounts': accountBox.values.map(_accountToMap).toList(),
      'categories': categoryBox.values.map(_categoryToMap).toList(),
      'transactions': transactionBox.values.map(_transactionToMap).toList(),
      'budgets': budgetBox.values.map(_budgetToMap).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Let user pick a location and save JSON backup. Returns path or null.
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

    if (Platform.isAndroid) {
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
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(json);
      return file.path;
    }
  }

  /// Export all transactions to CSV string
  String exportToCsv() {
    final accountBox = Hive.box<Account>(HiveBoxes.accounts);
    final categoryBox = Hive.box<Category>(HiveBoxes.categories);
    final transactionBox = Hive.box<Transaction>(HiveBoxes.transactions);

    final accounts = {for (final a in accountBox.values) a.id: a.name};
    final categories = {for (final c in categoryBox.values) c.id: c.name};

    final buf = StringBuffer();
    buf.writeln('Date,Type,Amount,Category,From Account,To Account,Note');

    final txs = transactionBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final fmt = DateFormat('dd/MM/yyyy');

    for (final tx in txs) {
      final date = fmt.format(tx.date);
      final type = tx.type.name;
      final amount = tx.amount.toString();
      final category = _csvField(categories[tx.categoryId] ?? '');
      final fromAccount = _csvField(accounts[tx.fromAccountId] ?? 'Unknown');
      final toAccount = _csvField(
        tx.toAccountId != null ? (accounts[tx.toAccountId] ?? 'Unknown') : '',
      );
      final note = _csvField(tx.note);

      buf.writeln('$date,$type,$amount,$category,$fromAccount,$toAccount,$note');
    }

    return buf.toString();
  }

  /// CSV-escape a field: wrap in quotes if it contains comma, quote, or newline
  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Let user pick a location and save CSV. Returns path or null.
  Future<String?> exportCsvToUserLocation() async {
    final csv = exportToCsv();
    final now = DateTime.now();
    final ts =
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${(now.year % 100).toString().padLeft(2, '0')}';
    final fileName = 'artakula_transactions_$ts.csv';

    if (Platform.isAndroid) {
      return _pickAndSaveOnAndroid(fileName, csv);
    }

    final dirPath = await getDirectoryPath(
      confirmButtonText: 'Save Here',
    );

    if (dirPath == null) return null;

    try {
      final file = File('$dirPath/$fileName');
      await file.writeAsString(csv);
      return file.path;
    } catch (_) {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(csv);
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

    if (!_isValidBackupJson(json)) {
      throw FormatException('File is not a valid Artakula backup');
    }

    await importFromJson(json);
    return path;
  }

  /// Validate that a JSON string has the Artakula backup structure
  bool _isValidBackupJson(String json) {
    try {
      final data = jsonDecode(json);
      if (data is! Map) return false;
      final map = data;
      return map['version'] is int &&
          (map['version'] as int) >= 1 &&
          map['accounts'] is List &&
          map['categories'] is List &&
          map['transactions'] is List;
    } catch (_) {
      return false;
    }
  }

  /// Import from a JSON string (replaces all data)
  Future<void> importFromJson(String json) async {
    var data = jsonDecode(json) as Map<String, dynamic>;
    final version = data['version'] as int? ?? 1;

    if (version > _currentBackupVersion) {
      throw FormatException(
        'Backup was created by a newer version of the app. '
        'Please update the app to restore this backup.',
      );
    }

    for (var v = version; v < _currentBackupVersion; v++) {
      data = _migrate(v, data);
    }

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

  /// Migrate data from [fromVersion] to the next version.
  /// Returns the transformed data map.
  Map<String, dynamic> _migrate(int fromVersion, Map<String, dynamic> data) {
    switch (fromVersion) {
      // In the future, add cases like:
      // case 1: return _migrateV1ToV2(data);
      default:
        throw ArgumentError('Unknown backup version: $fromVersion');
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
