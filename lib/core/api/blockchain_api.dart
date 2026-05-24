import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

class BlockchainApi {
  BlockchainApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> dashboard() async {
    final r = await _dio.get('/blockchain/dashboard');
    return Map<String, dynamic>.from(r.data['data'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> status() async {
    final r = await _dio.get('/blockchain/status');
    return Map<String, dynamic>.from(r.data['data'] as Map? ?? {});
  }

  Future<Map<String, dynamic>> receipt(int id) async {
    final r = await _dio.get('/blockchain/receipts/$id');
    return Map<String, dynamic>.from(r.data['data'] as Map? ?? {});
  }
}

final blockchainApiProvider = Provider<BlockchainApi>((ref) {
  return BlockchainApi(ref.watch(dioProvider));
});