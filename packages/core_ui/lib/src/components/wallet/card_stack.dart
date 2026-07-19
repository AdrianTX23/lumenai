import 'dart:async';

import 'package:core_ui/src/components/wallet/payment_card.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/utils/lds_haptics.dart';
import 'package:flutter/widgets.dart';

/// Display data for one card in a [CardStack].
final class CardStackItem {
  /// Creates a stack item.
  const CardStackItem({
    required this.accountName,
    required this.last4,
    required this.network,
    required this.skinIndex,
    this.balanceMinorUnits,
  });

  /// Account display name.
  final String accountName;

  /// Masked digits.
  final String last4;

  /// Network label.
  final String network;

  /// Gradient skin.
  final int skinIndex;

  /// Optional balance.
  final int? balanceMinorUnits;
}

/// Apple-Wallet-style stack: the selected card sits in front, the rest
/// peek behind. Tapping a background card springs it forward; the stack
/// also responds to vertical drags. Purely presentational — selection
/// state lives here, data comes from the caller.
class CardStack extends StatefulWidget {
  /// Creates a card stack.
  const CardStack({
    required this.items,
    this.onSelected,
    this.width = 320,
    super.key,
  });

  /// Cards, front-most meaning `selected == index`.
  final List<CardStackItem> items;

  /// Notifies when a card is brought to the front.
  final ValueChanged<int>? onSelected;

  /// Card width; the stack sizes itself from it.
  final double width;

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  int _selected = 0;

  static const _peek = 44.0;

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    unawaited(LdsHaptics.thud());
    widget.onSelected?.call(index);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 200 && _selected > 0) {
      _select(_selected - 1);
    } else if (velocity < -200 && _selected < widget.items.length - 1) {
      _select(_selected + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.width / 1.586;
    final height = cardHeight + _peek * (widget.items.length - 1);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Depth order: unselected cards from back to front, selected last.
    final order = [
      for (var i = 0; i < widget.items.length; i++)
        if (i != _selected) i,
      _selected,
    ];

    return GestureDetector(
      onVerticalDragEnd: _onDragEnd,
      child: SizedBox(
        width: widget.width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final index in order)
              AnimatedPositioned(
                key: ValueKey('card-$index'),
                duration: reduceMotion ? Duration.zero : LdsMotion.emphasized,
                curve: LdsMotion.emphasizedEasing,
                top: _topFor(index),
                child: GestureDetector(
                  onTap: () => _select(index),
                  child: AnimatedScale(
                    duration:
                        reduceMotion ? Duration.zero : LdsMotion.emphasized,
                    curve: LdsMotion.emphasizedEasing,
                    scale: index == _selected ? 1 : 0.96,
                    child: PaymentCard(
                      accountName: widget.items[index].accountName,
                      last4: widget.items[index].last4,
                      network: widget.items[index].network,
                      skinIndex: widget.items[index].skinIndex,
                      balanceMinorUnits:
                          index == _selected // Only the front card shows
                              ? widget.items[index].balanceMinorUnits
                              : null, // money — the rest stay glanceable.
                      width: widget.width,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Selected card sits at the bottom slot; the others stack above it in
  /// their relative order, each peeking by [_peek].
  double _topFor(int index) {
    final behind = [
      for (var i = 0; i < widget.items.length; i++)
        if (i != _selected) i,
    ];
    if (index == _selected) return _peek * behind.length;
    return _peek * behind.indexOf(index).toDouble();
  }
}
