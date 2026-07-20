/// User's theme preference. `system` (the default) follows the OS
/// setting; `light`/`dark` pin it.
enum AppThemeMode {
  /// Follow the OS light/dark setting.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}
