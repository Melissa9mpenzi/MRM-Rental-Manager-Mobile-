import 'package:flutter/foundation.dart';

/// Legacy helpers; prefer [apiUrlProvider] for the live base URL.
class ApiConfig {
  static const _placeholderHosts = {'your_pc_ip', 'your-pc-ip'};

  static bool isInvalidHost(String baseUrl) {
    if (kIsWeb) return false;
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) return true;
    final host = uri.host.toLowerCase();
    if (_placeholderHosts.contains(host)) return true;
    if (host.contains('your_pc') || host.contains('your-pc')) return true;
    return false;
  }

  static String misconfigurationHint(String baseUrl) {
    if (!isInvalidHost(baseUrl)) return '';
    return 'Tap "Server settings" below and enter your PC Wi‑Fi IP from ipconfig, '
        'e.g. http://192.168.1.2:8000\n'
        'On PC run: uvicorn app.main:app --host 0.0.0.0 --port 8000';
  }
}
