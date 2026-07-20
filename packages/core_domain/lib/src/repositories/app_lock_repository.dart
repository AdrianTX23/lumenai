import 'package:core_domain/src/failures/result.dart';

/// Port: biometric app-lock capability and its enabled/disabled state.
abstract interface class AppLockRepository {
  /// Whether the device has biometrics enrolled and available.
  Future<bool> isBiometricAvailable();

  /// Whether the user has turned app-lock on.
  Future<bool> isLockEnabled();

  /// Turns app-lock on or off. Enabling prompts biometric authentication
  /// first, so a lock can never be turned on without proving the current
  /// user can pass it. [reason] is shown in the platform prompt —
  /// presentation supplies it so the adapter never owns user-facing copy.
  Future<Result<void>> setLockEnabled({
    required bool enabled,
    required String reason,
  });

  /// Prompts the platform biometric UI with [reason] and reports the
  /// outcome.
  Future<Result<void>> authenticate({required String reason});
}
