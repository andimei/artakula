import 'package:flutter/material.dart';
import 'package:artakula/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/hive/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerHiveAdapters();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const ShellPage(),
    );
  }
}
