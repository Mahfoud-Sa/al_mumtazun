import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

// ================= STATES =================

abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<dynamic> users;

  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersError extends UsersState {
  final String message;

  UsersError(this.message);

  @override
  List<Object?> get props => [message];
}

// ================= CUBIT =================

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  final String baseUrl = 'http://al-mumtazun-api.runasp.net/api/Users';

  // ================= FETCH USERS =================

  Future<void> fetchUsers() async {
    emit(UsersLoading());

    try {
      final resp = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': 'text/plain'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body);

        if (body is List) {
          emit(UsersLoaded(body));
          return;
        }

        if (body is Map && body['data'] is List) {
          emit(UsersLoaded(body['data']));
          return;
        }

        emit(UsersLoaded([body]));
        return;
      }

      emit(UsersError('HTTP ${resp.statusCode} ${resp.reasonPhrase}'));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  // ================= ACTIVATE USER =================

  Future<bool> activateUser(int id) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/toggleActive/$id'),
        headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await fetchUsers();
        return true;
      }

      emit(UsersError('فشل التفعيل: ${resp.statusCode}'));

      return false;
    } catch (e) {
      emit(UsersError(e.toString()));
      return false;
    }
  }

  // ================= DEACTIVATE USER =================

  Future<bool> deactivateUser(int id) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/toggleActive/$id'),
        headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await fetchUsers();
        return true;
      }

      emit(UsersError('فشل التعطيل: ${resp.statusCode}'));

      return false;
    } catch (e) {
      emit(UsersError(e.toString()));
      return false;
    }
  }

  // ================= UPDATE USER =================

  Future<bool> updateUser({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final resp = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await fetchUsers();
        return true;
      }

      emit(UsersError('فشل التعديل: ${resp.statusCode}'));

      return false;
    } catch (e) {
      emit(UsersError(e.toString()));
      return false;
    }
  }
}
