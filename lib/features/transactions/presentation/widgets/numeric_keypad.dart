import 'package:artakula/features/transactions/presentation/widgets/keypad_button.dart';
import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String key) onKeyTap;
  final VoidCallback onClear;

  const NumericKeypad({
    super.key,
    required this.onKeyTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KeypadRow(
          keys: const ["7", "8", "9"],
          onKeyTap: onKeyTap,
          onClear: onClear,
        ),
        _KeypadRow(
          keys: const ["4", "5", "6"],
          onKeyTap: onKeyTap,
          onClear: onClear,
        ),
        _KeypadRow(
          keys: const ["1", "2", "3"],
          onKeyTap: onKeyTap,
          onClear: onClear,
        ),
        _KeypadRow(
          keys: const [",", "0", "del"],
          onKeyTap: onKeyTap,
          onClear: onClear,
        ),
      ],
    );
  }
}

class _KeypadRow extends StatelessWidget {
  final List<String> keys;
  final Function(String) onKeyTap;
  final VoidCallback onClear;

  const _KeypadRow({
    required this.keys,
    required this.onKeyTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: KeypadButton(
                key: ValueKey(key),
                label: key,
                onTap: () {
                  if (key == ",") return;
                  onKeyTap(key);
                },
                onLongpress: key == "del" ? onClear : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
