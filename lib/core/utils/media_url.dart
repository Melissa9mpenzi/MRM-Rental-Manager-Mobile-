import 'package:rental_mgr_mobile/core/config/api_url_store.dart';

String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('/images/')) return '';
  if (path.startsWith('http')) return path;
  final base = currentApiBaseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}
