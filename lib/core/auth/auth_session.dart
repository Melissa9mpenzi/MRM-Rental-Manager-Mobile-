import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rental_mgr_mobile/core/models/app_user.dart';

const _kAccess = 'access_token';
const _kRefresh = 'refresh_token';
const _kUser = 'user_json';

class AuthSession {
  AuthSession({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<AppUser?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null || raw.isEmpty) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required AppUser user,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    await _storage.write(key: _kUser, value: jsonEncode(user.toJson()));
  }

  Future<void> saveUser(AppUser user) async {
    await _storage.write(key: _kUser, value: jsonEncode(user.toJson()));
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _kAccess, value: token);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}
