import 'package:dio/dio.dart';

/// Mirrors web `apiErrorMessage` — FastAPI `detail` string or `{ message }`.
String apiErrorMessage(Object error, [String fallback = 'Something went wrong.']) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is Map && detail['message'] is String) {
        return detail['message'] as String;
      }
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) return first['msg'] as String;
      }
      if (data['message'] is String) return data['message'] as String;
    }
    return error.message ?? fallback;
  }
  if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
  return fallback;
}
