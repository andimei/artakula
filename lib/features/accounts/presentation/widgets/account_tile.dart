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
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE0E0E0),
              ),
            ),
          ),
          child: Row(
            children: [
              // icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // color: acc.color,
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  account.icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              /// NAME
              Expanded(
                child: Text(
                  account.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              dragHandle ??
                  const Icon(
                    Icons.dehaze,
                    size: 26,
                    color: Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );

    // return InkWell(
    //   onTap: onTap,
    //   child: Container(
    //     padding: const EdgeInsets.symmetric(
    //       horizontal: 16,
    //       vertical: 14,
    //     ),
    //     decoration: const BoxDecoration(
    //       color: Colors.white,
    //       border: Border(
    //         bottom: BorderSide(
    //           color: Color(0xFFE0E0E0),
    //         ),
    //       ),
    //     ),
    //     child: Row(
    //       children: [
    //         Expanded(
    //           child: Text(
    //             account.name,
    //             style: const TextStyle(
    //               fontSize: 16,
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),

    //         Text(
    //           rupiah.format(balance),
    //           style: const TextStyle(
    //             fontSize: 15,
    //             fontWeight: FontWeight.w600,
    //           ),
    //         ),

    //         const SizedBox(width: 6),

    //         const Icon(
    //           Icons.chevron_right,
    //           size: 18,
    //           color: Colors.grey,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
