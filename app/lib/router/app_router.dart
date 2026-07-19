import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_app/features/home/presentation/screens/home_screen.dart';
import 'package:lumen_app/router/routes.dart';

/// Router as a provider so guards can depend on app state
/// (onboarding-completed, app-lock) once those features land.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home.path,
    routes: [
      GoRoute(
        name: AppRoutes.home.name,
        path: AppRoutes.home.path,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
