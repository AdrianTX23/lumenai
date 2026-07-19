/// A month-long analytics window anchored to a configurable day.
///
/// Users paid on the 25th think in salary cycles, not calendar months —
/// every aggregation in LUMEN groups by [Period] so that logic exists
/// exactly once. The window is `[start, end)`: start inclusive, end
/// exclusive. Anchor days beyond a month's length clamp to its last day
/// (anchor 31 in February → Feb 28/29).
final class Period {
  const Period._(this.start, this.end);

  /// The period with [anchorDay] that contains [containing].
  factory Period.monthly({
    required DateTime containing,
    int anchorDay = 1,
  }) {
    if (anchorDay < 1 || anchorDay > 31) {
      throw ArgumentError.value(anchorDay, 'anchorDay', 'must be 1..31');
    }
    final date = DateTime(containing.year, containing.month, containing.day);
    var start = _anchored(date.year, date.month, anchorDay);
    if (date.isBefore(start)) {
      start = _anchored(date.year, date.month - 1, anchorDay);
    }
    final end = _anchored(start.year, start.month + 1, anchorDay);
    return Period._(start, end);
  }

  /// Inclusive start (midnight, local).
  final DateTime start;

  /// Exclusive end (midnight, local).
  final DateTime end;

  /// Day the window anchors on (its start day).
  int get anchorDay => start.day;

  /// The window immediately before this one.
  Period get previous => Period.monthly(
        containing: start.subtract(const Duration(days: 1)),
        anchorDay: _anchorOf(this),
      );

  /// The window immediately after this one.
  Period get next =>
      Period.monthly(containing: end, anchorDay: _anchorOf(this));

  /// Whether [moment] falls inside `[start, end)`.
  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  /// Clamps [day] into the last valid day of (year, month) and returns the
  /// resulting date. Month may be out of 1..12 and is normalized.
  static DateTime _anchored(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }

  /// Recovers the intended anchor from a period whose start may be clamped
  /// (a Feb 28 start from anchor 31 must stay anchor 31, not become 28).
  static int _anchorOf(Period period) {
    final lastDayOfStartMonth =
        DateTime(period.start.year, period.start.month + 1, 0).day;
    final startsOnLastDay = period.start.day == lastDayOfStartMonth;
    // If the window starts on its month's final day, the true anchor is the
    // larger of the two window edges' days (31 survives via the end month).
    if (startsOnLastDay) {
      return period.end.day > period.start.day
          ? period.end.day
          : period.start.day;
    }
    return period.start.day;
  }

  @override
  bool operator ==(Object other) =>
      other is Period && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'Period(${start.toIso8601String()} → '
      '${end.toIso8601String()})';
}
