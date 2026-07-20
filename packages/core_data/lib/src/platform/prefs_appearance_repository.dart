import 'package:core_domain/core_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AppearanceRepository] backed by `shared_preferences`.
final class PrefsAppearanceRepository implements AppearanceRepository {
  /// Creates the adapter.
  const PrefsAppearanceRepository();

  static const _themeModeKey = 'lumen.appearance.theme_mode';

  @override
  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModeKey);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => AppThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
