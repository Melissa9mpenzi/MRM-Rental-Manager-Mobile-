import 'package:dio/dio.dart';

/// Mirrors web `apiErrorMessage` — FastAPI `detail` string or `{ message }`.
String apiErrorMessage(Object error, [String fallback = 'Something went wrong.']) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Cannot reach the server in time. Check that the backend is running '
          '(uvicorn --host 0.0.0.0 --port 8000), phone and PC are on the same Wi‑Fi, '
          'and you used your real PC IP in API_BASE_URL (not your_pc_ip).';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'No connection to the API. Use your PC Wi‑Fi IP: '
          'flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000';
    }
    final data = error.response?.data;
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is Map) {
        if (detail['message'] is String) return detail['message'] as String;
        if (detail['msg'] is String) return detail['msg'] as String;
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
