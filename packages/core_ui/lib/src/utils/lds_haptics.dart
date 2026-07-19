import 'package:flutter/services.dart';

/// Haptic vocabulary. Components call these instead of `HapticFeedback`
/// directly so the feel is tuned in one place.
abstract final class LdsHaptics {
  /// Button presses, chip toggles.
  static Future<void> tap() => HapticFeedback.lightImpact();

  /// Sheet snaps, card-stack settle.
  static Future<void> thud() => HapticFeedback.mediumImpact();

  /// Destructive confirmations, errors.
  static Future<void> warn() => HapticFeedback.heavyImpact();

  /// Selection ticks while scrubbing charts.
  static Future<void> tick() => HapticFeedback.selectionClick();
}
