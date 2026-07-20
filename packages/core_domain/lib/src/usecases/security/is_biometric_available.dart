import 'package:core_domain/src/repositories/app_lock_repository.dart';

/// Whether the device can offer biometric app-lock at all.
final class IsBiometricAvailable {
  /// Creates the use case.
  const IsBiometricAvailable(this._appLock);

  final AppLockRepository _appLock;

  /// Checks availability.
  Future<bool> call() => _appLock.isBiometricAvailable();
}
