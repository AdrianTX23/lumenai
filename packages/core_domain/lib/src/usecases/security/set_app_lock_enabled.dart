import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/app_lock_repository.dart';

/// Turns app-lock on or off (onboarding and settings).
final class SetAppLockEnabled {
  /// Creates the use case.
  const SetAppLockEnabled(this._appLock);

  final AppLockRepository _appLock;

  /// Applies the new [enabled] state, showing [reason] if a biometric
  /// prompt is needed to confirm it.
  Future<Result<void>> call({required bool enabled, required String reason}) =>
      _appLock.setLockEnabled(enabled: enabled, reason: reason);
}
