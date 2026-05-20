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

  /// Live vs mock Flutterwave configuration.
  Future<Map<String, dynamic>> gatewayStatus() async {
    final res = await _dio.get<Map<String, dynamic>>('/payments/gateway/status');
    return res.data ?? {};
  }

  /// `GET /payments/wallet-summary` — totals visible to the current user.
  Future<Map<String, dynamic>> walletSummary() async {
    final res = await _dio.get<Map<String, dynamic>>('/payments/wallet-summary');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _dio.post<Map<String, dynamic>>('/payments', data: body);
    return res.data ?? {};
  }

  /// Start MoMo/card checkout for an invoice (`POST /payments/checkout/initiate`).
  Future<Map<String, dynamic>> initiateCheckout({
    required int invoiceId,
    required String paymentMethod,
    String? phone,
    num? amount,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/payments/checkout/initiate',
      data: {
        'invoice_id': invoiceId,
        'payment_method': paymentMethod,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (amount != null) 'amount': amount,
      },
    );
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> getCheckout(String reference) async {
    final res = await _dio.get<Map<String, dynamic>>('/payments/checkout/$reference');
    return res.data ?? {};
  }

}
