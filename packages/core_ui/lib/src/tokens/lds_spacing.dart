/// Spacing scale on a 4-pt base. No magic paddings anywhere in the app.
abstract final class LdsSpacing {
  /// 4 — icon-to-text gaps, chip innards.
  static const double xxs = 4;

  /// 8 — tight sibling gaps.
  static const double xs = 8;

  /// 12 — intra-card padding.
  static const double sm = 12;

  /// 16 — default screen gutter and card padding.
  static const double md = 16;

  /// 20 — comfortable card padding.
  static const double lg = 20;

  /// 24 — section gaps.
  static const double xl = 24;

  /// 32 — large section breaks.
  static const double xxl = 32;

  /// 40 — hero top spacing.
  static const double xxxl = 40;

  /// 56 — page-level breathing room.
  static const double jumbo = 56;
}

/// Corner radii. Card corners are large and continuous by design.
abstract final class LdsRadius {
  /// 10 — chips, small controls.
  static const double sm = 10;

  /// 16 — buttons, inputs.
  static const double md = 16;

  /// 24 — sheets, large tiles.
  static const double lg = 24;

  /// 28 — cards (the signature LUMEN corner).
  static const double card = 28;

  /// Effectively circular.
  static const double full = 999;
}
