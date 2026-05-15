import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Settings', style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: IconButton(
              icon: Icon(_themeIcon(themeMode)),
              onPressed: () {
                ref.read(themeProvider.notifier).toggle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
