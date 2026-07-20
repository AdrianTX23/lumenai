import 'package:core_domain/src/repositories/app_lock_repository.dart';

/// Whether the user has app-lock turned on.
final class IsAppLockEnabled {
  /// Creates the use case.
  const IsAppLockEnabled(this._appLock);

  final AppLockRepository _appLock;

  /// Checks the current setting.
  Future<bool> call() => _appLock.isLockEnabled();
}
