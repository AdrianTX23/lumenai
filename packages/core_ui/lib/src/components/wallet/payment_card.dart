import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_palette.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:core_ui/src/utils/lds_money_format.dart';
import 'package:flutter/widgets.dart';

/// Gradient skins for [PaymentCard]. Indexes are stable — accounts store
/// a skin index, not colors.
abstract final class LdsCardSkins {
  /// The available card gradients, ordered by skin index.
  static const gradients = <List<Color>>[
    // 0 — Lumen glow (teal).
    [Color(0xFF063B34), Color(0xFF0B8A7A), Color(0xFF38E1C6)],
    // 1 — Midnight violet.
    [Color(0xFF1B1140), Color(0xFF4A2FA5), Color(0xFF8B6BF2)],
    // 2 — Graphite.
    [Color(0xFF10151F), Color(0xFF242C3F), Color(0xFF39435A)],
    // 3 — Ember.
    [Color(0xFF3B1120), Color(0xFF8A2F4A), Color(0xFFE05B7A)],
  ];

  /// Gradient for [skinIndex], wrapping safely.
  static List<Color> of(int skinIndex) =>
      gradients[skinIndex % gradients.length];
}

/// The visual payment card: gradient skin, account name, masked number,
/// network and optional balance. Fixed 1.586 aspect (ISO 7810 ID-1).
class PaymentCard extends StatelessWidget {
  /// Creates a payment card visual.
  const PaymentCard({
    required this.accountName,
    required this.last4,
    required this.network,
    this.skinIndex = 0,
    this.balanceMinorUnits,
    this.currencyCode = 'EUR',
    this.width = 320,
    super.key,
  });

  /// Account display name (top-left).
  final String accountName;

  /// Last four digits — the only PAN data that ever exists in the app.
  final String last4;

  /// Network label (bottom-right).
  final String network;

  /// Index into [LdsCardSkins].
  final int skinIndex;

  /// Optional balance shown under the name.
  final int? balanceMinorUnits;

  /// ISO 4217 code for the balance.
  final String currencyCode;

  /// Card width; height follows the ID-1 aspect ratio.
  final double width;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final height = width / 1.586;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(LdsSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LdsRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: LdsCardSkins.of(skinIndex),
        ),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountName,
            style: lds.typography.label.copyWith(
              color: LdsPalette.neutral50,
              letterSpacing: 0.4,
            ),
          ),
          if (balanceMinorUnits != null) ...[
            const SizedBox(height: LdsSpacing.xxs),
            Text(
              LdsMoneyFormat.format(
                balanceMinorUnits!,
                currencyCode: currencyCode,
                compact: true,
              ),
              style: lds.typography.moneyXl.copyWith(
                color: LdsPalette.neutral50,
                fontSize: 26,
              ),
            ),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '••••  $last4',
                style: lds.typography.money.copyWith(
                  color: LdsPalette.neutral50,
                  letterSpacing: 2,
                ),
              ),
              Text(
                network.toUpperCase(),
                style: lds.typography.caption.copyWith(
                  color: const Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
