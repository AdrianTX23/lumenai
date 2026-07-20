import 'package:core_domain/src/repositories/appearance_repository.dart';
import 'package:core_domain/src/value_objects/app_theme_mode.dart';

/// Reads the user's persisted theme preference.
final class GetThemeMode {
  /// Creates the use case.
  const GetThemeMode(this._appearance);

  final AppearanceRepository _appearance;

  /// Reads the preference.
  Future<AppThemeMode> call() => _appearance.getThemeMode();
}
