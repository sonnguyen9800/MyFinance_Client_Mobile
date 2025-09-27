import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight abstraction around key/value persistence that works on both
/// mobile (secure storage) and web (shared preferences / local storage).
abstract class AppStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll(Iterable<String> keys);
}

class _SecureStorageAdapter implements AppStorage {
  _SecureStorageAdapter(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      await _storage.delete(key: key);
    }
  }

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

class _SharedPreferencesAdapter implements AppStorage {
  _SharedPreferencesAdapter(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }
}

Future<AppStorage> createAppStorage(
    {SharedPreferences? sharedPreferences}) async {
  if (kIsWeb) {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    return _SharedPreferencesAdapter(prefs);
  }

  return _SecureStorageAdapter(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        keyCipherAlgorithm:
            KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
        sharedPreferencesName: 'myfinance_secure_prefs',
      ),
    ),
  );
}
