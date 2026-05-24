import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

class ReceiptsApi {
  ReceiptsApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> list({int limit = 50}) async {
    final r = await _dio.get('/receipts', queryParameters: {'limit': limit});
    final data = r.data;
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data'] as List);
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> get(int id) async {
    final r = await _dio.get('/receipts/$id');
    return Map<String, dynamic>.from(r.data['data'] as Map? ?? r.data as Map? ?? {});
  }

  Future<Map<String, dynamic>> verify(String token) async {
    final r = await _dio.get('/receipts/verify/$token');
    return Map<String, dynamic>.from(r.data['data'] as Map? ?? {});
  }

  String pdfPath(int id) => '/receipts/$id/pdf';
}

final receiptsApiProvider = Provider<ReceiptsApi>((ref) {
  return ReceiptsApi(ref.watch(dioProvider));
});
