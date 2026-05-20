import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final tenantApiProvider = Provider<TenantApi>((ref) => TenantApi(ref.watch(dioProvider)));

class TenantApi {
  TenantApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>?> myLease() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/tenant/my-lease');
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<dynamic>> myPayments() async {
    final res = await _dio.get<dynamic>('/tenant/my-payments');
    final data = res.data;
    return data is List ? data : [];
  }

  Future<List<dynamic>> myInvoices() async {
    final res = await _dio.get<dynamic>('/tenant/my-invoices');
    final data = res.data;
    return data is List ? data : [];
  }
}
