import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final workspaceApiProvider =
    Provider<WorkspaceApi>((ref) => WorkspaceApi(ref.watch(dioProvider)));

class WorkspaceApi {
  WorkspaceApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> adminSummary() async {
    final res = await _dio.get<Map<String, dynamic>>('/workspace/admin/summary');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> staffSummary() async {
    final res = await _dio.get<Map<String, dynamic>>('/workspace/staff/summary');
    return res.data ?? {};
  }

  Future<List<dynamic>> adminUsers({String? search, String? role}) async {
    final res = await _dio.get<dynamic>(
      '/workspace/admin/users',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        'limit': 30,
      },
    );
    final data = res.data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return [];
  }

  Future<void> kycReview(int userId, String action) async {
    await _dio.patch('/workspace/admin/users/$userId/kyc-review', data: {'action': action});
  }
}
