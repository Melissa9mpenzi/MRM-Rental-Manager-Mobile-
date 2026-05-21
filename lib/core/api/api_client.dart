import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/auth/auth_session.dart';
import 'package:rental_mgr_mobile/core/config/api_url_store.dart';

final authSessionProvider = Provider<AuthSession>((ref) => AuthSession());

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authSessionProvider);
  final apiV1 = ref.watch(apiUrlProvider.notifier).apiV1;
  return createDio(session, apiV1);
});

Dio createDio(AuthSession session, String apiV1Base) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiV1Base,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.data is FormData) {
          options.headers.remove('Content-Type');
        }
        final token = await session.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map &&
            data['success'] == true &&
            data.containsKey('data')) {
          response.data = data['data'];
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final req = error.requestOptions;
        if (error.response?.statusCode == 401 &&
            req.extra['_retried'] != true &&
            !_isAuthCredentialRequest(req.path)) {
          req.extra['_retried'] = true;
          final refresh = await session.refreshToken;
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: apiV1Base,
                  headers: {'Content-Type': 'application/json'},
                ),
              );
              final res = await refreshDio.post<Map<String, dynamic>>(
                '/auth/refresh',
                data: {'refresh_token': refresh},
              );
              final body = res.data;
              final newToken = body is Map<String, dynamic> ? body['access_token'] as String? : null;
              if (newToken != null) {
                await session.saveAccessToken(newToken);
                req.headers['Authorization'] = 'Bearer $newToken';
                final clone = await dio.fetch(req);
                return handler.resolve(clone);
              }
            } catch (_) {
              await session.clear();
            }
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

bool _isAuthCredentialRequest(String path) {
  return path.contains('/auth/login') ||
      path.contains('/auth/register') ||
      path.contains('/auth/firebase') ||
      path.contains('/auth/forgot-password') ||
      path.contains('/auth/reset-password') ||
      path.contains('/auth/verify-email');
}
