import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// Onboarding carousel + security opt-in state.
final class OnboardingUiState {
  /// Creates a state snapshot.
  const OnboardingUiState({
    this.pageIndex = 0,
    this.biometricAvailable = false,
    this.lockEnabled = false,
    this.isSaving = false,
  });

  /// Current carousel page.
  final int pageIndex;

  /// Whether this device can offer biometric app-lock at all.
  final bool biometricAvailable;

  /// Whether the user has opted into app-lock.
  final bool lockEnabled;

  /// Whether [OnboardingController.finish] is in flight.
  final bool isSaving;

  /// Copies with overrides.
  OnboardingUiState copyWith({
    int? pageIndex,
    bool? biometricAvailable,
    bool? lockEnabled,
    bool? isSaving,
  }) {
    return OnboardingUiState(
      pageIndex: pageIndex ?? this.pageIndex,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Drives the onboarding carousel and the optional biometric-lock opt-in.
final class OnboardingController extends Notifier<OnboardingUiState> {
  @override
  OnboardingUiState build() {
    unawaited(_checkBiometricAvailability());
    return const OnboardingUiState();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await ref.read(isBiometricAvailableProvider)();
    state = state.copyWith(biometricAvailable: available);
  }

  /// Updates the visible carousel page.
  void goToPage(int index) => state = state.copyWith(pageIndex: index);

  /// Toggles the app-lock opt-in on the security page.
  void setLockEnabled({required bool enabled}) =>
      state = state.copyWith(lockEnabled: enabled);

  /// Persists the app-lock choice (if any) and marks onboarding complete.
  ///
  /// Returns `false` if the user opted into app-lock but the biometric
  /// prompt failed — the caller should let them retry rather than
  /// silently continuing without the lock they asked for.
  Future<bool> finish({required String biometricReason}) async {
    state = state.copyWith(isSaving: true);

    if (state.lockEnabled) {
      final result = await ref.read(setAppLockEnabledProvider)(
        enabled: true,
        reason: biometricReason,
      );
      if (result.isErr) {
        state = state.copyWith(isSaving: false, lockEnabled: false);
        return false;
      }
    }

    await ref.read(completeOnboardingProvider)();
    state = state.copyWith(isSaving: false);
    return true;
  }
}

/// The active onboarding flow state.
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingUiState>(
  OnboardingController.new,
);
