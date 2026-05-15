import 'package:artakula/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            title: "Terang",
            subtitle: "Tampilan cerah",
            isSelected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            title: "Gelap",
            subtitle: "Tampilan gelap",
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
          ),
        ],
      ),
    );
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
      trailing: isSelected
          ? Icon(Icons.check, color: scheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
