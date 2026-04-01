import 'package:artakula/core/theme/theme_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class KeypadButton extends StatefulWidget {
//   final String label;
//   final VoidCallback onTap;
//   final VoidCallback? onLongpress;

//   const KeypadButton({
//     super.key,
//     required this.label,
//     required this.onTap,
//     this.onLongpress,
//   });

//   @override
//   State<KeypadButton> createState() => _KeypadButtonState();
// }

// class _KeypadButtonState extends State<KeypadButton> {
//   bool _pressed = false;

//   void _onTapDown(_) {
//     setState(() => _pressed = true);
//   }

//   void _onTapUp(_) {
//     setState(() => _pressed = false);
//   }

//   void _onCancel() {
//     setState(() => _pressed = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDelete = widget.label == "del";

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: widget.onTap,
//         onTapDown: _onTapDown,
//         onTapUp: _onTapUp,
//         onTapCancel: _onCancel,
//         onLongPress: widget.onLongpress,
//         borderRadius: BorderRadius.circular(2),
//         splashColor: context.colors.surfaceContainerHighest,
//         highlightColor: context.colors.surfaceContainerHighest,

//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 120),
//           curve: Curves.easeOut,
//           transform: Matrix4.identity()
//             ..scaleByDouble(
//               _pressed ? 0.97 : 1.0,
//               _pressed ? 0.97 : 1.0,
//               1.0,
//               1.0,
//             ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: _pressed
//                   ? context.colors.surfaceContainerHighest
//                   : context.colors.surfaceContainerLow,
//               borderRadius: BorderRadius.circular(2),
//             ),
//             alignment: Alignment.center,
//             child: isDelete
//                 ? const Icon(Icons.backspace_outlined, size: 28)
//                 : Text(
//                     widget.label,
//                     style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }


class KeypadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongpress;

  const KeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongpress,
  });

  @override
  State<KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<KeypadButton> {
  bool _pressed = false;

  void _press(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDelete = widget.label == "del";

    return GestureDetector(
      // behavior: HitTestBehavior.opaque,
       behavior: HitTestBehavior.translucent,

      ///  INSTANT RESPONSE
      onTapDown: (_) {
        _press(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _press(false);
        widget.onTap();
      },
      onTapCancel: () => _press(false),
      onLongPress: widget.onLongpress,

      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 70),
        curve: Curves.easeOut,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          decoration: BoxDecoration(
            color: _pressed
                ? scheme.surfaceContainerHighest
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: isDelete
              ? const Icon(Icons.backspace_outlined, size: 28)
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}