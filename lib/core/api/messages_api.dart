import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final messagesApiProvider = Provider<MessagesApi>((ref) => MessagesApi(ref.watch(dioProvider)));

/// Rental Hub — property-based messaging API.
class MessagesApi {
  MessagesApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> threads({String folder = 'inbox', String? q}) async {
    final res = await _dio.get<dynamic>(
      '/messages/threads',
      queryParameters: {
        'folder': folder,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>?> threadContext(int threadId) async {
    final res = await _dio.get<dynamic>('/messages/threads/$threadId/context');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  Future<List<dynamic>> threadMessages(int threadId) async {
    final res = await _dio.get<dynamic>('/messages/threads/$threadId/messages');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  Future<void> postMessage(int threadId, String body) async {
    await _dio.post('/messages/threads/$threadId/messages', data: {'body': body});
  }

  Future<int> startThread(int unitId, String body, {String threadType = 'inquiry'}) async {
    final res = await _dio.post<dynamic>(
      '/messages/start',
      data: {'unit_id': unitId, 'body': body, 'thread_type': threadType},
    );
    final data = res.data;
    if (data is Map) {
      return (data['thread_id'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> markRead(int threadId) async {
    await _dio.post('/messages/threads/$threadId/read');
  }

  Future<void> archiveThread(int threadId, {bool archived = true}) async {
    await _dio.post('/messages/threads/$threadId/archive', data: {'archived': archived});
  }
}
