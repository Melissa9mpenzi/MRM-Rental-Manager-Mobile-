import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final notificationsApiProvider =
    Provider<NotificationsApi>((ref) => NotificationsApi(ref.watch(dioProvider)));

class NotificationsApi {
  NotificationsApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> list() async {
    final res = await _dio.get<dynamic>('/notifications');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<int> unreadCount() async {
    final res = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return (res.data?['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int id) async {
    await _dio.post('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.post('/notifications/mark-all-read');
  }
}
