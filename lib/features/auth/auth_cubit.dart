import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  AuthState({required this.isLoggedIn, required this.isLoading, this.error});

  factory AuthState.initial() {
    return AuthState(isLoggedIn: false, isLoading: false, error: null);
  }

  AuthState copyWith({bool? isLoggedIn, bool? isLoading, String? error}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.initial());

  static const String baseUrl = 'http://al-mumtazun-api.runasp.net/api/Auth';

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'password': password}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          if (data["isActive"] == false) {
            // Save the token securely for future authenticated requests
            // For example, using flutter_secure_storage or shared_preferences
          }
        }
        emit(state.copyWith(isLoggedIn: true, isLoading: false, error: null));
      } else {
        String message = "فشل تسجيل الدخول";

        try {
          final data = jsonDecode(response.body);

          if (data["message"] != null) {
            message = data["message"];
          }
        } catch (_) {}

        emit(
          state.copyWith(isLoggedIn: false, isLoading: false, error: message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          error: "حدث خطأ في الاتصال بالخادم",
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(AuthState.initial());
  }
}
