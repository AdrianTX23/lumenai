import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generates and persists the database encryption key in the platform
/// keychain/keystore. The key itself never touches disk unencrypted and
/// survives app restarts, but not a fresh install (keychain items are
/// tied to the app's provisioning, which is the desired behavior — a
/// reinstalled app starts with a fresh encrypted store).
final class SqlCipherKeyStore {
  /// Creates the key store, optionally injecting a fake for tests.
  const SqlCipherKeyStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _keyName = 'lumen.db.encryption_key';

  /// Returns the persisted key, generating and storing a new
  /// cryptographically random 256-bit key (as hex) on first call.
  Future<String> getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _keyName);
    if (existing != null) return existing;

    final generated = _generateHexKey();
    await _secureStorage.write(key: _keyName, value: generated);
    return generated;
  }

  String _generateHexKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
