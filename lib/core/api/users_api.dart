import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';
import 'package:rental_mgr_mobile/core/models/app_user.dart';

final usersApiProvider = Provider<UsersApi>((ref) => UsersApi(ref.watch(dioProvider)));

class UsersApi {
  UsersApi(this._dio);
  final Dio _dio;

  Future<AppUser> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>('/users/me');
    return AppUser.fromJson(res.data!);
  }

  Future<AppUser> putMe({String? fullName, String? phone, String? role}) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (role != null) body['role'] = role == 'agent' ? 'staff' : role;
    final res = await _dio.put<Map<String, dynamic>>('/users/me', data: body);
    return AppUser.fromJson(res.data!);
  }

  Future<void> uploadKycDocuments({
    required MultipartFile idFront,
    required MultipartFile idBack,
    required MultipartFile selfie,
  }) async {
    final form = FormData.fromMap({
      'id_front': idFront,
      'id_back': idBack,
      'selfie': selfie,
    });
    await _dio.post(
      '/users/me/kyc-documents',
      data: form,
      options: Options(
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
  }

  Future<AppUser> kycSubmit() async {
    final res = await _dio.post<Map<String, dynamic>>('/users/me/kyc-submit');
    return AppUser.fromJson(res.data!);
  }
}
