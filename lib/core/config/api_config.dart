import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Same backend as the web app (`VITE_API_URL` → `http://localhost:8000` by default).
///
/// Override at run time:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
class ApiConfig {
  static const String _envBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Resolves host for device/emulator (Android emulator → 10.0.2.2).
  static String get baseUrl {
    var url = _envBase;
    if (!kIsWeb && Platform.isAndroid && url.contains('localhost')) {
      url = url.replaceFirst('localhost', '10.0.2.2');
    }
    return url.replaceAll(RegExp(r'/+$'), '');
  }

  static String get apiV1 => '$baseUrl/api/v1';
}
