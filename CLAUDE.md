# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Get dependencies
flutter pub get

# Generate Hive type adapters (.g.dart files)
flutter pub run build_runner build

# Watch mode for code generation
flutter pub run build_runner watch

# Run the app
flutter run

# Static analysis
flutter analyze

# Run tests
flutter test
```

## Architecture Overview

Personal finance app (Indonesian, "Artakula") built with Flutter + Riverpod + Hive.

### Folder Structure

```
lib/
├── core/                   # Cross-cutting concerns
│   ├── bootstrap/          # App initialization (Hive init, seed data)
│   ├── hive/               # Hive box names, adapter registration
│   ├── providers/          # Global providers (theme)
│   ├── services/           # Theme persistence
│   └── theme/              # M3 theme, colors, semantic color extension
├── features/               # Feature modules
│   ├── accounts/           # Account/rekening management
│   ├── budgets/            # Budget planning
│   ├── categories/         # Transaction categories
│   ├── overviews/          # Dashboard with charts (fl_chart)
│   ├── shell/              # Main shell with bottom nav bar
│   └── transactions/       # Core transaction CRUD
├── shared/widgets/         # Reusable shared widgets
└── main.dart               # Entry point with ProviderScope
```

Each feature follows a `data/` / `presentation/` structure:
- `data/` — Hive service layer, models, generated adapters
- `presentation/` — Pages, widgets
- `providers/` — Riverpod StateNotifier providers

### Data Layer

Hive boxes (no encryption, local-only):
- `accounts` — `Account` (typeId: 0) with custom icons
- `categories` — `Category` (typeId: 10) with income/expense flag, system categories
- `transactions` — `Transaction` (typeId: 20) supporting income/expense/transfer types
- `budgets` — `Budget` (typeId: 30) with weekly/monthly/yearly periods

After adding fields to Hive models, run `build_runner build` to regenerate `.g.dart` files.

### State Management (Riverpod)

- Each feature has a `StateNotifierProvider` wrapping a Hive service
- Notifiers use `_load()` to read from Hive on init
- Computed providers (e.g., `filteredTransactionProvider`, `accountBalanceProvider`) derive data reactively
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for pages

### Theme System

Custom `AppSemanticColors` `ThemeExtension` provides `income`, `expense`, `balance` colors.
Access via `context.semantic.income` (import `theme_ext.dart`).
Color scheme via `context.colors` (M3 ColorScheme).

### Key Patterns

- **Deletion with undo**: `TransactionNotifier.deleteWithUndo()` shows a SnackBar with UNDO action
- **Hive auto-listen**: `AccountNotifier` uses `_box.listenable().addListener(_onHiveChanged)` for reactive updates (other notifiers use explicit `_load()` after mutations)
- **Currency**: Integer-based (no decimals), formatted with `.` thousand separators
- **Navigation**: Standard `Navigator.push` with `MaterialPageRoute` (no named routes)
