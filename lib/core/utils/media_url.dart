import 'package:rental_mgr_mobile/core/config/api_config.dart';

String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = ApiConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}
