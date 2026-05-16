import 'package:artakula/core/theme/theme_ext.dart';
import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/account.dart';
import 'package:intl/intl.dart';

class AccountTile extends ConsumerWidget {
  final Account account;
  final VoidCallback? onTap;
  final Widget? dragHandle;

  const AccountTile({
    super.key,
    required this.account,
    this.onTap,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(accountBalanceProvider(account.id));

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  account.icon,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        account.name,
                        style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),

                    Text(
                      rupiah.format(balance),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              dragHandle ??
                  Icon(
                    Icons.dehaze,
                    size: 26,
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
            ],
          ),
        ),
      ),
    );

  }
}
