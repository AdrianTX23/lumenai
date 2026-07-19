/// Route table. Paths and names live here so navigation call sites never
/// hardcode strings. Typed route data classes arrive with go_router_builder
/// when parameterized routes appear (Phase 3).
abstract final class AppRoutes {
  /// Home tab — net worth, cards, recent activity.
  static const home = (name: 'home', path: '/');
}
