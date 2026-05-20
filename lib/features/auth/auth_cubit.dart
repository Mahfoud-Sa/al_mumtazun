import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/clients/http_client.dart';
import '../../core/storage/secure_auth_storage.dart';
import 'data/models/auth_session_model.dart';
import 'domain/entities/user.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final User? user;
  final DateTime? expiresAt;

  const AuthState({
    required this.isLoggedIn,
    required this.isLoading,
    required this.isInitialized,
    this.error,
    this.user,
    this.expiresAt,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoggedIn: false,
      isLoading: false,
      isInitialized: false,
    );
  }

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    User? user,
    DateTime? expiresAt,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : error ?? this.error,
      user: clearUser ? null : user ?? this.user,
      expiresAt: clearUser ? null : expiresAt ?? this.expiresAt,
    );
  }

  bool hasRole(String role) => user?.hasRole(role) ?? false;
  bool hasAnyRole(Iterable<String> roles) => roles.any(hasRole);
}

class AuthCubit extends Cubit<AuthState> {
  static const String baseUrl = 'http://al-mumtazun-api.runasp.net/api/Auth';

  final AppHttpClient httpClient;
  final SecureAuthStorage storage;

  AuthCubit({required this.httpClient, required this.storage})
    : super(AuthState.initial());

  Future<void> loadCurrent() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final session = await storage.readSession();

    if (session == null || session.token.isEmpty || _isExpired(session)) {
      await storage.clear();
      emit(
        state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          isInitialized: true,
          clearUser: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        isInitialized: true,
        user: session.user,
        expiresAt: session.expiresAt,
        clearError: true,
      ),
    );
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(
      state.copyWith(isLoading: true, isInitialized: true, clearError: true),
    );

    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'password': password}),
      );

      final data = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data is Map<String, dynamic>) {
        final success = data['success'];
        if (success == false) {
          throw Exception(_messageFrom(data, 'فشل تسجيل الدخول'));
        }

        final session = AuthSessionModel.fromJson(data);
        if (session.token.isEmpty) {
          throw Exception('لم يرجع الخادم رمز الدخول.');
        }
        if (!session.user.isActive) {
          await storage.clear();
          throw Exception('هذا الحساب غير مفعل.');
        }
        if (session.isExpired) {
          await storage.clear();
          throw Exception(
            'انتهت صلاحية جلسة الدخول. expiresAt=${session.expiresAt.toUtc().toIso8601String()} now=${DateTime.now().toUtc().toIso8601String()}',
          );
        }

        try {
          await storage.saveSession(session);
        } catch (_) {
          // The session is still valid for this runtime. Startup persistence will
          // be unavailable until secure storage is healthy on the device.
        }
        emit(
          state.copyWith(
            isLoggedIn: true,
            isLoading: false,
            isInitialized: true,
            user: session.user,
            expiresAt: session.expiresAt,
            clearError: true,
          ),
        );
        return;
      }

      final message = data is Map<String, dynamic>
          ? _messageFrom(data, 'فشل تسجيل الدخول')
          : 'فشل تسجيل الدخول';
      emit(
        state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          isInitialized: true,
          error: message,
          clearUser: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          isInitialized: true,
          error: error.toString().replaceFirst('Exception: ', ''),
          clearUser: true,
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await storage.clear();
    emit(
      state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        isInitialized: true,
        clearUser: true,
      ),
    );
  }

  bool _isExpired(AuthSessionModel session) {
    if (session.isExpired) return true;
    try {
      return JwtDecoder.isExpired(session.token);
    } catch (_) {
      return false;
    }
  }

  String _messageFrom(Map<String, dynamic> data, String fallback) {
    return data['message']?.toString().trim().isNotEmpty == true
        ? data['message'].toString()
        : fallback;
  }
}
