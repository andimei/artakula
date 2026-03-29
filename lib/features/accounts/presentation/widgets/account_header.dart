import 'package:artakula/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AccountHeader extends ConsumerWidget {
  const AccountHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalBalanceProvider);

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            rupiah.format(total),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),

          // const Icon(
          //   Icons.chevron_right,
          //   size: 18,
          //   color: Colors.grey,
          // ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }
}

// class AccountsHeader extends StatelessWidget {
//   const AccountsHeader({
//     super.key,
//     required this.onAdd,
//     this.onFilter,
//     this.onSettings,
//   });

//   final VoidCallback onAdd;
//   final VoidCallback? onFilter;
//   final VoidCallback? onSettings;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//       child: Row(
//         children: [
//           const Text(
//             'Accounts',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),

//           IconButton(
//             icon: const Icon(Icons.add),
//             tooltip: 'Add Account',
//             onPressed: onAdd,
//           ),
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             tooltip: 'Filter',
//             onPressed: onFilter,
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             tooltip: 'Settings',
//             onPressed: onSettings,
//           ),
//         ],
//       ),
//     );
//   }
// }
