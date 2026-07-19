/// Route table. Paths and names live here so navigation call sites never
/// hardcode strings.
abstract final class AppRoutes {
  /// Home tab — net worth, cards, recent activity.
  static const home = (name: 'home', path: '/');

  /// Activity tab — transaction feed.
  static const activity = (name: 'activity', path: '/activity');

  /// Insights tab (Phase 4).
  static const insights = (name: 'insights', path: '/insights');

  /// Copilot tab (Phase 5).
  static const copilot = (name: 'copilot', path: '/copilot');
}
