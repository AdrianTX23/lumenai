import 'package:core_domain/src/value_objects/app_theme_mode.dart';

/// Port: the user's persisted theme preference.
abstract interface class AppearanceRepository {
  /// The current preference, [AppThemeMode.system] by default.
  Future<AppThemeMode> getThemeMode();

  /// Persists a new preference.
  Future<void> setThemeMode(AppThemeMode mode);
}
