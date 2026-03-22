// import 'package:artakula/features/accounts/presentation/widgets/account_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/account_provider.dart';
import '../widgets/account_header.dart';
// import '../widgets/account_form.dart';
import '../widgets/account_tile.dart';
import 'package:artakula/features/accounts/presentation/pages/account_form_page.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);

    return Column(
      children: [
        Card(
          color: const Color(0xFF2E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ),
        ),
        // const Divider(height: 1),
        AccountsHeader(
          onAdd: () {
            // open add account page / bottom sheet
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AccountFormPage(),
              ),
            );
          },
          onFilter: () {
            // open filter
          },
          onSettings: () {
            // open settings
          },
        ),

        const Divider(height: 1),
        Expanded(
          child: accounts.isEmpty
              ? const Center(child: Text('No accounts yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return AccountTile(
                      account: account,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountFormPage(account: account),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
