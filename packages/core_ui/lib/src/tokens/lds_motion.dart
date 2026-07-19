import 'package:flutter/animation.dart';

/// Motion tokens. Rules: motion is always spatial (things come from
/// somewhere), and every animated widget must respect
/// `MediaQuery.disableAnimations`.
abstract final class LdsMotion {
  /// 120ms — state flips (hover, selection, icon swaps).
  static const fast = Duration(milliseconds: 120);

  /// 240ms — standard transitions (fades, small movement).
  static const standard = Duration(milliseconds: 240);

  /// 400ms — emphasized movement (sheets, drill-ins).
  static const emphasized = Duration(milliseconds: 400);

  /// 600ms — celebratory moments (count-ups, chart entry).
  static const celebratory = Duration(milliseconds: 600);

  /// Default easing for standard transitions.
  static const standardEasing = Cubic(0.2, 0, 0, 1);

  /// Overshoot-free emphasized easing for large movement.
  static const emphasizedEasing = Cubic(0.05, 0.7, 0.1, 1);
}
