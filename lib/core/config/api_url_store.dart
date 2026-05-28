import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'api_base_url';

/// Resolves API host for emulator vs physical device.
String resolveApiBaseUrl(String url) {
  var u = url.trim().replaceAll(RegExp(r'/+$'), '');
  if (!kIsWeb && Platform.isAndroid && u.contains('localhost')) {
    u = u.replaceFirst('localhost', '10.0.2.2');
  }
  return u;
}

/// Production backend (Vercel). Override with --dart-define=API_BASE_URL=... when building.
const productionApiBaseUrl = 'https://mrm-rental-manager-backend.vercel.app';

String _defaultFromEnvironment() {
  const env = String.fromEnvironment('API_BASE_URL');
  if (env.isNotEmpty) return env;
  // Never default to localhost in production/release builds.
  if (kReleaseMode) return productionApiBaseUrl;
  if (kIsWeb) return productionApiBaseUrl;
  // Physical phone cannot use localhost — set your PC IP in Server settings.
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://192.168.1.2:8000';
  }
  return 'http://localhost:8000';
}

final apiUrlProvider = StateNotifierProvider<ApiUrlNotifier, String>((ref) {
  return ApiUrlNotifier();
});

/// Sync access for utilities without [Ref] (e.g. image URLs).
String get currentApiBaseUrl => ApiUrlNotifier.cachedBase;

class ApiUrlNotifier extends StateNotifier<String> {
  ApiUrlNotifier() : super(resolveApiBaseUrl(_defaultFromEnvironment())) {
    cachedBase = state;
  }

  static String cachedBase = resolveApiBaseUrl(_defaultFromEnvironment());

  bool _loaded = false;
  bool get isLoaded => _loaded;

  void _apply(String url) {
    state = url;
    cachedBase = url;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _apply(resolveApiBaseUrl(saved));
    } else {
      _apply(resolveApiBaseUrl(_defaultFromEnvironment()));
    }
    _loaded = true;
  }

  Future<void> setBaseUrl(String url) async {
    final resolved = resolveApiBaseUrl(url);
    _apply(resolved);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, resolved);
    _loaded = true;
  }

  String get apiV1 => '$state/api/v1';
}
