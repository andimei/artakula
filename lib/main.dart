import 'package:artakula/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:artakula/features/shell/presentation/pages/shell_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
    final bootstrap = ref.watch(appBootstrapProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      home: bootstrap.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
        data: (_) => const ShellPage(),
      ),
    );
  }
}