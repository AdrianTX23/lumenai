import 'package:core_domain/src/repositories/appearance_repository.dart';
import 'package:core_domain/src/value_objects/app_theme_mode.dart';

/// Persists a new theme preference (settings screen).
final class SetThemeMode {
  /// Creates the use case.
  const SetThemeMode(this._appearance);

  final AppearanceRepository _appearance;

  /// Applies [mode].
  Future<void> call(AppThemeMode mode) => _appearance.setThemeMode(mode);
}
