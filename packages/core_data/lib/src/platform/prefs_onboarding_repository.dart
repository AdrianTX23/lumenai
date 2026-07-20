import 'package:core_domain/core_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [OnboardingRepository] backed by `shared_preferences` — not sensitive
/// data, so it doesn't need the secure-storage adapters do.
final class PrefsOnboardingRepository implements OnboardingRepository {
  /// Creates the adapter.
  const PrefsOnboardingRepository();

  static const _completedKey = 'lumen.onboarding.completed';

  @override
  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  @override
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }
}
