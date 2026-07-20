/// Route table. Paths and names live here so navigation call sites never
/// hardcode strings.
abstract final class AppRoutes {
  /// Home tab — net worth, cards, recent activity.
  static const home = (name: 'home', path: '/');

  /// Activity tab — transaction feed.
  static const activity = (name: 'activity', path: '/activity');

  /// Insights tab.
  static const insights = (name: 'insights', path: '/insights');

  /// Budgets — pushed from Insights (docs/03-design-system.md §4: a 5th
  /// tab would dilute the IA).
  static const budgets = (name: 'budgets', path: 'budgets');

  /// Copilot tab (Phase 5).
  static const copilot = (name: 'copilot', path: '/copilot');

  /// First-run onboarding (Phase 6). Outside the tab shell.
  static const onboarding = (name: 'onboarding', path: '/onboarding');

  /// Biometric unlock prompt (Phase 6). Outside the tab shell.
  static const lock = (name: 'lock', path: '/lock');

  /// Settings — pushed from Home (Phase 6).
  static const settings = (name: 'settings', path: '/settings');
}
