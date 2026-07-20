import 'package:core_domain/core_domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// [AppLockRepository] backed by the platform's biometric prompt
/// (`local_auth`) and secure storage for the enabled/disabled flag.
final class BiometricLockRepository implements AppLockRepository {
  /// Creates the adapter, optionally injecting fakes for tests.
  BiometricLockRepository({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const _enabledKey = 'lumen.app_lock.enabled';

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> isLockEnabled() async {
    final value = await _secureStorage.read(key: _enabledKey);
    return value == 'true';
  }

  @override
  Future<Result<void>> setLockEnabled({
    required bool enabled,
    required String reason,
  }) async {
    if (enabled) {
      final authResult = await authenticate(reason: reason);
      if (authResult.isErr) return authResult;
    }
    try {
      await _secureStorage.write(
        key: _enabledKey,
        value: enabled.toString(),
      );
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(
        StorageFailure('could not persist app-lock setting: $e'),
      );
    }
  }

  @override
  Future<Result<void>> authenticate({required String reason}) async {
    if (!await isBiometricAvailable()) {
      return const Result.err(AuthFailure('biometrics unavailable'));
    }
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      return didAuthenticate
          ? const Result.ok(null)
          : const Result.err(
              AuthFailure('authentication failed or was cancelled'),
            );
    } on Exception catch (e) {
      return Result.err(AuthFailure('biometric prompt error: $e'));
    }
  }
}
