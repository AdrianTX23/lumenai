import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/app_lock_repository.dart';

/// Prompts biometric authentication to unlock the app.
final class AuthenticateWithAppLock {
  /// Creates the use case.
  const AuthenticateWithAppLock(this._appLock);

  final AppLockRepository _appLock;

  /// Runs the platform biometric prompt, showing [reason].
  Future<Result<void>> call({required String reason}) =>
      _appLock.authenticate(reason: reason);
}
