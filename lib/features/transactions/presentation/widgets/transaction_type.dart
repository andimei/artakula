import 'package:artakula/features/transactions/data/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionTypeSegment extends StatelessWidget {
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeSegment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = TransactionType.values;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / items.length;

          return Container(
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // SLIDING INDICATOR
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(
                    _alignmentX(value),
                    0,
                  ),
                  child: Container(
                    width: width,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _color(value),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                /// BUTTONS
                Row(
                  children: items.map((type) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(type),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: value == type
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            child: Text(_nameType(type)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _nameType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return "Income";
      case TransactionType.expense:
        return "Expense";
      case TransactionType.transfer:
        return "Transfer";
    }
  }

  /// posisi indicator
  double _alignmentX(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return -1;
      case TransactionType.expense:
        return 0;
      case TransactionType.transfer:
        return 1;
    }
  }

  /// warna fintech feel
  Color _color(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
    }
  }
}
