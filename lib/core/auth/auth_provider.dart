import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mgr_mobile/core/api/api_client.dart';
import 'package:rental_mgr_mobile/core/api/api_error.dart';
import 'package:rental_mgr_mobile/core/api/auth_api.dart';
import 'package:rental_mgr_mobile/core/api/users_api.dart';
import 'package:rental_mgr_mobile/core/auth/auth_session.dart';
import 'package:rental_mgr_mobile/core/models/app_user.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.bootstrapped = false,
  });

  final AppUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool bootstrapped;

  AuthState copyWith({
    AppUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    bool? bootstrapped,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      bootstrapped: bootstrapped ?? this.bootstrapped,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authSessionProvider),
    ref.watch(authApiProvider),
    ref.watch(usersApiProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._session, this._authApi, this._usersApi) : super(const AuthState());

  final AuthSession _session;
  final AuthApi _authApi;
  final UsersApi _usersApi;

  Future<void> bootstrap() async {
    final token = await _session.accessToken;
    if (token == null || token.isEmpty) {
      state = state.copyWith(bootstrapped: true, isAuthenticated: false, user: null);
      return;
    }
    try {
      final user = await _authApi.me();
      await _session.saveUser(user);
      state = AuthState(user: user, isAuthenticated: true, bootstrapped: true);
    } catch (_) {
      await _session.clear();
      state = const AuthState(bootstrapped: true);
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String role = 'tenant',
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authApi.register(
        fullName: fullName,
        email: email.trim(),
        phone: phone,
        password: password,
        role: role,
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> verifyEmail({required String email, required String token}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authApi.verifyEmail(email: email.trim(), token: token.trim());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AppUser> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authApi.login(email: email.trim(), password: password);
      await _session.saveSession(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
      );
      state = AuthState(
        user: result.user,
        isAuthenticated: true,
        bootstrapped: true,
      );
      return result.user;
    } catch (e) {
      throw Exception(apiErrorMessage(e, 'Login failed. Check your credentials.'));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AppUser> updateRole(String uiRole) async {
    state = state.copyWith(isLoading: true);
    try {
      final apiRole = uiRole == 'agent' ? 'staff' : uiRole;
      final user = await _usersApi.putMe(role: apiRole);
      await _session.saveUser(user);
      state = state.copyWith(user: user);
      return user;
    } catch (e) {
      throw Exception(apiErrorMessage(e, 'Could not update role.'));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<AppUser> submitKyc({
    MultipartFile? idFront,
    MultipartFile? idBack,
    MultipartFile? selfie,
    required bool needsDocs,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      if (needsDocs) {
        if (idFront == null || idBack == null || selfie == null) {
          throw Exception('Add ID front, ID back, and a portrait selfie.');
        }
        await _usersApi.uploadKycDocuments(
          idFront: idFront,
          idBack: idBack,
          selfie: selfie,
        );
      }
      final user = await _usersApi.kycSubmit();
      await _session.saveUser(user);
      state = state.copyWith(user: user);
      return user;
    } catch (e) {
      throw Exception(apiErrorMessage(e, 'KYC upload failed.'));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateUser(AppUser user) {
    _session.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> refreshProfile() async {
    final user = await _usersApi.getMe();
    await _session.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      return await _authApi.forgotPassword(email.trim());
    } catch (e) {
      throw Exception(apiErrorMessage(e, 'Could not send reset code.'));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authApi.resetPassword(email: email.trim(), otp: otp.trim(), newPassword: newPassword);
    } catch (e) {
      throw Exception(apiErrorMessage(e, 'Password reset failed.'));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    await _session.clear();
    state = const AuthState(bootstrapped: true);
  }
}
