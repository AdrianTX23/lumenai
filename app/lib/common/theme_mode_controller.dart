import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// The active theme preference, loaded once from storage and updated by
/// the settings screen. Starts as [AppThemeMode.system] so the very
/// first frame renders with the right theme immediately, then reconciles
/// with the persisted value once that read resolves.
final class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    unawaited(_load());
    return AppThemeMode.system;
  }

  Future<void> _load() async {
    state = await ref.read(getThemeModeProvider)();
  }

  /// Persists and applies a new preference.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await ref.read(setThemeModeProvider)(mode);
  }
}

/// The active theme preference.
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
  ThemeModeController.new,
);

/// Maps the domain preference to Flutter's [ThemeMode].
extension AppThemeModeMapping on AppThemeMode {
  /// The equivalent Flutter [ThemeMode].
  ThemeMode get toFlutterThemeMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}
