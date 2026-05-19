import 'package:artakula/core/providers/theme_provider.dart';
import 'package:artakula/features/backup/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _backupService = BackupService();

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const _SectionHeader(title: "Tampilan"),
          _ThemeOption(
            icon: Icons.brightness_auto,
            title: "System",
            subtitle: "Ikuti pengaturan sistem",
            isSelected: themeMode == ThemeMode.system,
            onTap: () =>
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            title: "Terang",
            subtitle: "Tampilan cerah",
            isSelected: themeMode == ThemeMode.light,
            onTap: () =>
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            title: "Gelap",
            subtitle: "Tampilan gelap",
            isSelected: themeMode == ThemeMode.dark,
            onTap: () =>
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
          ),

          const _SectionHeader(title: "Data"),
          _ActionTile(
            icon: Icons.table_chart_outlined,
            title: "Export CSV",
            subtitle: "Simpan transaksi ke file CSV",
            onTap: () => _doExportCsv(context),
          ),
          _ActionTile(
            icon: Icons.backup,
            title: "Backup Data",
            subtitle: "Simpan backup ke file JSON",
            onTap: () => _doBackup(context),
          ),
          _ActionTile(
            icon: Icons.restore,
            title: "Restore Data",
            subtitle: "Restore dari file backup",
            onTap: () => _doRestore(context),
          ),
        ],
      ),
    );
  }

  Future<void> _doExportCsv(BuildContext context) async {
    try {
      final path = await _backupService.exportCsvToUserLocation();

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved:\n$path'),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV export failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _doBackup(BuildContext context) async {
    try {
      final path = await _backupService.exportToUserLocation();

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved:\n$path'),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _doRestore(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace ALL existing data. Cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final path = await _backupService.pickAndImport();

      if (!context.mounted) return;

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restore failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? scheme.primary : null),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected ? Icon(Icons.check, color: scheme.primary) : null,
      onTap: onTap,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
