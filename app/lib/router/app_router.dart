import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_app/features/activity/presentation/screens/activity_screen.dart';
import 'package:lumen_app/features/app_lock/presentation/screens/lock_screen.dart';
import 'package:lumen_app/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:lumen_app/features/copilot/presentation/screens/copilot_screen.dart';
import 'package:lumen_app/features/home/presentation/screens/home_screen.dart';
import 'package:lumen_app/features/insights/presentation/screens/insights_screen.dart';
import 'package:lumen_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:lumen_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:lumen_app/router/app_gate_controller.dart';
import 'package:lumen_app/router/app_shell.dart';
import 'package:lumen_app/router/routes.dart';

/// Dev affordance: launch on a specific route with
/// `--dart-define=LUMEN_INITIAL_LOCATION=/activity` (deep-link testing,
/// screenshot capture). Only honored once the gate is [AppGateReady] —
/// a fresh install still sees onboarding first.
const _initialLocationOverride =
    String.fromEnvironment('LUMEN_INITIAL_LOCATION');

/// Notifies go_router whenever [AppGateController]'s state changes, so
/// `redirect` gets re-evaluated without a manual navigation trigger.
final class _GateRefreshListenable extends ChangeNotifier {
  _GateRefreshListenable(Ref ref) {
    ref.listen(appGateControllerProvider, (_, __) => notifyListeners());
  }
}

/// Router as a provider so `redirect` can depend on app state
/// (onboarding-completed, app-lock) via [appGateControllerProvider].
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _GateRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: _initialLocationOverride.isEmpty
        ? AppRoutes.home.path
        : _initialLocationOverride,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final gate = ref.read(appGateControllerProvider);
      final location = state.matchedLocation;
      return switch (gate) {
        // Nothing to redirect to yet — the current route (or the
        // default initial one) renders under a loading gate briefly.
        AppGateLoading() => null,
        AppGateNeedsOnboarding() => location == AppRoutes.onboarding.path
            ? null
            : AppRoutes.onboarding.path,
        AppGateNeedsUnlock() =>
          location == AppRoutes.lock.path ? null : AppRoutes.lock.path,
        AppGateReady() => (location == AppRoutes.onboarding.path ||
                location == AppRoutes.lock.path)
            ? AppRoutes.home.path
            : null,
      };
    },
    routes: [
      GoRoute(
        name: AppRoutes.onboarding.name,
        path: AppRoutes.onboarding.path,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.lock.name,
        path: AppRoutes.lock.path,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.home.name,
                path: AppRoutes.home.path,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.activity.name,
                path: AppRoutes.activity.path,
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.insights.name,
                path: AppRoutes.insights.path,
                builder: (context, state) => const InsightsScreen(),
                routes: [
                  GoRoute(
                    name: AppRoutes.budgets.name,
                    path: AppRoutes.budgets.path,
                    builder: (context, state) => const BudgetsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRoutes.copilot.name,
                path: AppRoutes.copilot.path,
                builder: (context, state) => const CopilotScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
