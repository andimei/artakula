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

          /// 🔥 Theme toggle row
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

// class AppDrawer extends StatelessWidget {
//   final ThemeMode themeMode;
//   final ValueChanged<ThemeMode> onThemeChanged;

//   const AppDrawer({
//     super.key,
//     required this.themeMode,
//     required this.onThemeChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             child: const Text(
//               'Settings',
//               style: TextStyle(color: Colors.white, fontSize: 20),
//             ),
//           ),

//           ListTile(
//             leading: const Icon(Icons.brightness_auto),
//             title: const Text('System Theme'),
//             trailing: themeMode == ThemeMode.system
//                 ? const Icon(Icons.check)
//                 : null,
//             onTap: () {
//               onThemeChanged(ThemeMode.system);
//               Navigator.pop(context);
//             },
//           ),

//           ListTile(
//             leading: const Icon(Icons.light_mode),
//             title: const Text('Light Mode'),
//             trailing: themeMode == ThemeMode.light
//                 ? const Icon(Icons.check)
//                 : null,
//             onTap: () {
//               onThemeChanged(ThemeMode.light);
//               Navigator.pop(context);
//             },
//           ),

//           ListTile(
//             leading: const Icon(Icons.dark_mode),
//             title: const Text('Dark Mode'),
//             trailing: themeMode == ThemeMode.dark
//                 ? const Icon(Icons.check)
//                 : null,
//             onTap: () {
//               onThemeChanged(ThemeMode.dark);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
