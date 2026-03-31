import 'package:artakula/core/theme/theme_ext.dart';
import 'package:flutter/material.dart';

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

  void _onTapDown(_) {
    setState(() => _pressed = true);
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
  }

  void _onCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDelete = widget.label == "del";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onCancel,
        onLongPress: widget.onLongpress,
        borderRadius: BorderRadius.circular(2),
        splashColor: context.colors.surfaceContainerHighest,
        highlightColor: context.colors.surfaceContainerHighest,

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
          child: Container(
            decoration: BoxDecoration(
              color: _pressed
                  ? context.colors.surfaceContainerHighest
                  : context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: isDelete
                ? const Icon(Icons.backspace_outlined, size: 28)
                : Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        // child: AnimatedScale(
        //   scale: _pressed ? 0.9 : 1,
        //   duration: const Duration(milliseconds: 90),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: _pressed ? context.colors.surfaceContainerHighest : context.colors.surfaceContainerLow,
        //       borderRadius: BorderRadius.circular(2),
        //     ),
        //     alignment: Alignment.center,
        //     child: isDelete
        //         ? const Icon(Icons.backspace_outlined, size: 28)
        //         : Text(
        //             widget.label,
        //             style: const TextStyle(
        //               fontSize: 28,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //   ),
        // ),
      ),
    );
  }
}
