import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final dashboardApiProvider =
    Provider<DashboardApi>((ref) => DashboardApi(ref.watch(dioProvider)));

class DashboardApi {
  DashboardApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> stats() async {
    final res = await _dio.get<Map<String, dynamic>>('/dashboard/stats');
    return res.data ?? {};
  }
}
