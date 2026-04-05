import 'package:artakula/features/accounts/controller/account_provider.dart';
import 'package:artakula/features/accounts/data/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountGroupCard extends StatelessWidget {
  const AccountGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // _Header(group: group),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // itemCount: group.accounts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              // return AccountItem(
              //   account: group.accounts[index],
              // );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AccountGroup group;

  const _Header({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: group.color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            group.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "Assets: ${_formatCurrency(group.totalAsset)}",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class AccountItem extends StatelessWidget {
  final Account account;

  const AccountItem({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(account.icon, size: 40),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(account.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                "IDR (1.0)",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
