import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class FintechField extends StatelessWidget {
//   final String label;
//   final String? value;
//   final VoidCallback onTap;
//   final IconData? icon;

//   const FintechField({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.onTap,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 12,
//         ),
//         decoration: BoxDecoration(
//           color: scheme.surface,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// LABEL
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: scheme.onSurfaceVariant,
//               ),
//             ),

//             const SizedBox(height: 4),

//             /// VALUE
//             Row(
//               children: [
//                 if (icon != null) ...[
//                   Icon(icon, size: 18),
//                   const SizedBox(width: 6),
//                 ],
//                 Expanded(
//                   child: Text(
//                     value ?? "-",
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: scheme.onSurface,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class FintechField extends StatefulWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;

  final bool enable;

  const FintechField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.enable = true,
  });

  @override
  State<FintechField> createState() => _FintechFieldState();
}

class _FintechFieldState extends State<FintechField> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.enable ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: widget.enable
          ? () => setState(() => _pressed = false)
          : null,
      onTapUp: widget.enable
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scaleByDouble(
            _pressed ? 0.97 : 1.0,
            _pressed ? 0.97 : 1.0,
            1.0,
            1.0,
          ),

        decoration: BoxDecoration(
          color: _pressed ? scheme.surfaceContainerHighest : scheme.surface,
          borderRadius: BorderRadius.circular(8),

          /// subtle fintech shadow
          boxShadow: [
            if (!_pressed)
              BoxShadow(
                color: Color.fromARGB(19, 182, 172, 172),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LABEL
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 4),

            /// VALUE
            Opacity(
              opacity: widget.enable ? 1 : 0.5,
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      widget.value ?? "Select",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.value == null
                            ? scheme.outline
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
