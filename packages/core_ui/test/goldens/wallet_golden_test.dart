import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../helpers/golden_helpers.dart';

void main() {
  ldsGoldenPair(
    fileName: 'payment_card',
    scenarios: {
      'lumen glow with balance': const PaymentCard(
        accountName: 'Lumen Current',
        last4: '4821',
        network: 'Visa',
        balanceMinorUnits: 184230,
      ),
      'violet skin': const PaymentCard(
        accountName: 'Rainy Day',
        last4: '7710',
        network: 'Visa',
        skinIndex: 1,
      ),
      'graphite skin': const PaymentCard(
        accountName: 'Lumen Card',
        last4: '9034',
        network: 'Mastercard',
        skinIndex: 2,
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'card_stack',
    constraints: const BoxConstraints(maxWidth: 380, maxHeight: 360),
    scenarios: {
      'three cards': const CardStack(
        items: [
          CardStackItem(
            accountName: 'Lumen Current',
            last4: '4821',
            network: 'Visa',
            skinIndex: 0,
            balanceMinorUnits: 184230,
          ),
          CardStackItem(
            accountName: 'Rainy Day',
            last4: '7710',
            network: 'Visa',
            skinIndex: 1,
          ),
          CardStackItem(
            accountName: 'Lumen Card',
            last4: '9034',
            network: 'Mastercard',
            skinIndex: 2,
          ),
        ],
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'bottom_bar_and_search',
    scenarios: {
      'bottom bar': _StatelessBar(),
      'search field': const LdsSearchField(
        hint: 'Search merchants or notes',
        onChanged: _noopString,
      ),
    },
  );
}

void _noopString(String _) {}

class _StatelessBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LdsBottomBar(
      selectedIndex: 0,
      onSelected: (_) {},
      items: const [
        LdsBottomBarItem(icon: Icons.home_rounded, label: 'Home'),
        LdsBottomBarItem(icon: Icons.receipt_long_rounded, label: 'Activity'),
        LdsBottomBarItem(icon: Icons.donut_small_rounded, label: 'Insights'),
        LdsBottomBarItem(icon: Icons.auto_awesome_rounded, label: 'Copilot'),
      ],
    );
  }
}
