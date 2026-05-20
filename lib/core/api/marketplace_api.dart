import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';

final marketplaceApiProvider =
    Provider<MarketplaceApi>((ref) => MarketplaceApi(ref.watch(dioProvider)));

class MarketplaceApi {
  MarketplaceApi(this._dio);
  final Dio _dio;

  Future<List<dynamic>> listings({
    String search = '',
    double? minRent,
    double? maxRent,
    String? unitType,
  }) async {
    final res = await _dio.get<dynamic>(
      '/marketplace/listings',
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (minRent != null) 'min_rent': minRent,
        if (maxRent != null) 'max_rent': maxRent,
        if (unitType != null && unitType.isNotEmpty) 'unit_type': unitType,
      },
    );
    final data = res.data;
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> listing(int unitId) async {
    final res = await _dio.get<Map<String, dynamic>>('/marketplace/listings/$unitId');
    return res.data ?? {};
  }
}
