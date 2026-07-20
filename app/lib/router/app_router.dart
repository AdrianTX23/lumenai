import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_app/features/activity/presentation/screens/activity_screen.dart';
import 'package:lumen_app/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:lumen_app/features/copilot/presentation/screens/copilot_screen.dart';
import 'package:lumen_app/features/home/presentation/screens/home_screen.dart';
import 'package:lumen_app/features/insights/presentation/screens/insights_screen.dart';
import 'package:lumen_app/router/app_shell.dart';
import 'package:lumen_app/router/routes.dart';

/// Dev affordance: launch on a specific route with
/// `--dart-define=LUMEN_INITIAL_LOCATION=/activity` (deep-link testing,
/// screenshot capture). Empty in normal builds.
const _initialLocationOverride =
    String.fromEnvironment('LUMEN_INITIAL_LOCATION');

/// Router as a provider so guards can depend on app state
/// (onboarding-completed, app-lock) once those features land.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _initialLocationOverride.isEmpty
        ? AppRoutes.home.path
        : _initialLocationOverride,
    routes: [
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
