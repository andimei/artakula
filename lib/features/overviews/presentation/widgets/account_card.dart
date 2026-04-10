import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AccountSnapshotCard extends ConsumerWidget {
  const AccountSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final total = ref.watch(totalBalanceProvider);

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Actual balance",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                Text(
                  rupiah.format(total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// ACCOUNTS
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
            ),
            itemBuilder: (context, index) {
              final account = accounts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: AccountItem(account: account),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountItem extends ConsumerWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountItem({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(accountBalanceProvider(account.id));
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.account_balance_wallet),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            rupiah.format(balance),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
