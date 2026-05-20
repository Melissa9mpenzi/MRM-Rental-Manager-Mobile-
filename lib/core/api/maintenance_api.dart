import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final maintenanceApiProvider =
    Provider<MaintenanceApi>((ref) => MaintenanceApi(ref.watch(dioProvider)));

class MaintenanceApi {
  MaintenanceApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> list() async {
    final res = await _dio.get<dynamic>('/maintenance');
    final data = res.data;
    return data is List ? data : [];
  }
}
