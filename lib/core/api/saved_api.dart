import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final savedApiProvider = Provider<SavedApi>((ref) => SavedApi(ref.watch(dioProvider)));

class SavedApi {
  SavedApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> list() async {
    final res = await _dio.get<dynamic>('/saved-units');
    final data = res.data;
    return data is List ? data : [];
  }

  Future<void> add(int unitId) async {
    await _dio.post('/saved-units', data: {'unit_id': unitId});
  }

  Future<void> remove(int unitId) async {
    await _dio.delete('/saved-units/$unitId');
  }
}
