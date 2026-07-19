import 'package:core_ui/src/components/display/amount_text.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:flutter/widgets.dart';

/// Count-up rendering of an amount: animates from the previously shown
/// value to the new one (celebratory duration). Renders through
/// [AmountText], so sign/color/tabular policy stays in one place. Jumps
/// instantly under reduced motion.
class AnimatedAmount extends StatelessWidget {
  /// Creates an animated amount display.
  const AnimatedAmount(
    this.minorUnits, {
    required this.currencyCode,
    this.emphasis = AmountEmphasis.hero,
    this.colored = false,
    this.locale = 'en',
    super.key,
  });

  /// Target amount in minor units.
  final int minorUnits;

  /// ISO 4217 code.
  final String currencyCode;

  /// Visual emphasis preset.
  final AmountEmphasis emphasis;

  /// Whether income coloring applies (heroes usually keep primary color).
  final bool colored;

  /// BCP-47 locale tag.
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return AmountText(
        minorUnits,
        currencyCode: currencyCode,
        emphasis: emphasis,
        colored: colored,
        locale: locale,
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: minorUnits.toDouble()),
      duration: LdsMotion.celebratory,
      curve: LdsMotion.emphasizedEasing,
      builder: (context, value, _) => AmountText(
        value.round(),
        currencyCode: currencyCode,
        emphasis: emphasis,
        colored: colored,
        locale: locale,
      ),
    );
  }
}
