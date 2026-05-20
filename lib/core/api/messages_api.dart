import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final messagesApiProvider = Provider<MessagesApi>((ref) => MessagesApi(ref.watch(dioProvider)));

class MessagesApi {
  MessagesApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> threads() async {
    final res = await _dio.get<dynamic>('/messages/threads');
    final data = res.data;
    if (data is List) return data;
    return [];
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

  Future<int> startThread(int unitId, String body) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/messages/start',
      data: {'unit_id': unitId, 'body': body},
    );
    return (res.data?['thread_id'] as num?)?.toInt() ?? 0;
  }
}
