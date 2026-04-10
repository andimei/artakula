import 'package:flutter/material.dart';
import '../../data/models/category.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final Widget? dragHandle; // ⭐ tambahan

  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.isIncome ? Colors.green : Colors.red;

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
              /// ICON
              CircleAvatar(
                backgroundColor: color,
                child: Icon(
                  category.icon,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              /// NAME
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              /// DRAG HANDLE
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
  }
}

// class CategoryTile extends StatelessWidget {
//   final Category category;
//   final VoidCallback onTap;
//   final Widget? dragHandle;

//   const CategoryTile({
//     super.key,
//     required this.category,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = category.isIncome ? Colors.green : Colors.red;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           decoration: const BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Color(0xFFE0E0E0),
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: color,
//                 child: Icon(
//                   category.icon,
//                   color: Colors.white,
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Text(
//                   category.name,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),

//               const Icon(
//                 Icons.dehaze,
//                 size: 26,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
