import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// What the app should show before the normal tab shell: first-run
/// onboarding, a biometric unlock prompt, or (once past both) the app
/// itself.
sealed class AppGateState {
  const AppGateState();
}

/// Checking onboarding/lock status; nothing to show yet.
final class AppGateLoading extends AppGateState {
  /// Creates the loading state.
  const AppGateLoading();
}

/// First run — onboarding hasn't been completed.
final class AppGateNeedsOnboarding extends AppGateState {
  /// Creates the needs-onboarding state.
  const AppGateNeedsOnboarding();
}

/// App-lock is on and the current session hasn't unlocked yet.
final class AppGateNeedsUnlock extends AppGateState {
  /// Creates the needs-unlock state.
  const AppGateNeedsUnlock();
}

/// Clear to show the normal tab shell.
final class AppGateReady extends AppGateState {
  /// Creates the ready state.
  const AppGateReady();
}

/// Drives [AppGateState] from onboarding/app-lock settings and from the
/// app's foreground/background lifecycle — backgrounding past
/// [_relockThreshold] re-arms the lock, mirroring how iOS/Android banking
/// apps behave.
final class AppGateController extends Notifier<AppGateState>
    with WidgetsBindingObserver {
  static const _relockThreshold = Duration(seconds: 30);

  DateTime? _pausedAt;

  @override
  AppGateState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    unawaited(_evaluateInitialState());
    return const AppGateLoading();
  }

  Future<void> _evaluateInitialState() async {
    final onboarded = await ref.read(isOnboardingCompletedProvider)();
    if (!onboarded) {
      state = const AppGateNeedsOnboarding();
      return;
    }
    final lockEnabled = await ref.read(isAppLockEnabledProvider)();
    state = lockEnabled ? const AppGateNeedsUnlock() : const AppGateReady();
  }

  /// Called once the onboarding flow (including any lock opt-in) is done.
  void finishOnboarding() => state = const AppGateReady();

  /// Called once the unlock prompt succeeds.
  void unlock() => state = const AppGateReady();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pausedAt = DateTime.now();
      case AppLifecycleState.resumed:
        unawaited(_relockIfDue());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _relockIfDue() async {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    // Only a ready session can be re-locked — mid-onboarding or an
    // already-pending unlock prompt shouldn't be interrupted.
    if (pausedAt == null || state is! AppGateReady) return;
    if (DateTime.now().difference(pausedAt) < _relockThreshold) return;

    final lockEnabled = await ref.read(isAppLockEnabledProvider)();
    if (lockEnabled) state = const AppGateNeedsUnlock();
  }
}

/// The app's onboarding/lock/ready gate.
final appGateControllerProvider =
    NotifierProvider<AppGateController, AppGateState>(AppGateController.new);
