import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final paymentsApiProvider =
    Provider<PaymentsApi>((ref) => PaymentsApi(ref.watch(dioProvider)));

class PaymentsApi {
  PaymentsApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> list({Map<String, dynamic>? params}) async {
    final res = await _dio.get<dynamic>('/payments', queryParameters: params);
    final data = res.data;
    return data is List ? data : [];
  }
}
