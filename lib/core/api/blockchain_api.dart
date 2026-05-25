import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

Map<String, dynamic> _map(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

List<dynamic> _list(dynamic data) {
  if (data is List) return data;
  return [];
}

class BlockchainApi {
  BlockchainApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> dashboard() async {
    final r = await _dio.get('/blockchain/dashboard');
    return _map(r.data);
  }

  Future<Map<String, dynamic>> status() async {
    final r = await _dio.get('/blockchain/status');
    return _map(r.data);
  }

  Future<Map<String, dynamic>> walrusInventory() async {
    final r = await _dio.get('/blockchain/walrus/inventory');
    return _map(r.data);
  }

  Future<Map<String, dynamic>> myWallet() async {
    final r = await _dio.get('/blockchain/wallet/me');
    return _map(r.data);
  }

  Future<List<dynamic>> listReceipts({int limit = 50}) async {
    final r = await _dio.get('/blockchain/receipts', queryParameters: {'limit': limit});
    return _list(r.data);
  }

  Future<List<dynamic>> listEscrows() async {
    final r = await _dio.get('/blockchain/escrow');
    return _list(r.data);
  }

  Future<Map<String, dynamic>> receipt(int id) async {
    final r = await _dio.get('/blockchain/receipts/$id');
    return _map(r.data);
  }
}

final blockchainApiProvider = Provider<BlockchainApi>((ref) {
  return BlockchainApi(ref.watch(dioProvider));
});
