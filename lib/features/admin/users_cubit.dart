import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;

  UsersLoaded({
    required this.users,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [users, page, size, totalCount, totalPages];
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
  static const int defaultPageSize = 10;

  int _currentPage = 1;
  int _currentSize = defaultPageSize;

  // ================= FETCH USERS =================

  Future<void> fetchUsers({int? page, int? size}) async {
    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;

    emit(UsersLoading());

    try {
      final resp = await http.get(
        Uri.parse(baseUrl).replace(
          queryParameters: {
            'page': requestedPage.toString(),
            'size': requestedSize.toString(),
          },
        ),
        headers: {'accept': 'text/plain'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body);

        if (body is List) {
          _currentPage = requestedPage;
          _currentSize = requestedSize;
          emit(
            UsersLoaded(
              users: body,
              page: requestedPage,
              size: requestedSize,
              totalCount: body.length,
              totalPages: body.isEmpty ? 1 : 1,
            ),
          );
          return;
        }

        if (body is Map && body['data'] is List) {
          final users = body['data'] as List<dynamic>;
          final loadedPage = _readInt(body['page'], requestedPage);
          final loadedSize = _readInt(body['size'], requestedSize);
          final totalCount = _readInt(body['totalCount'], users.length);
          final totalPages = _readInt(body['totalPages'], 1);

          _currentPage = loadedPage;
          _currentSize = loadedSize;

          emit(
            UsersLoaded(
              users: users,
              page: loadedPage,
              size: loadedSize,
              totalCount: totalCount,
              totalPages: totalPages < 1 ? 1 : totalPages,
            ),
          );
          return;
        }

        _currentPage = requestedPage;
        _currentSize = requestedSize;
        emit(
          UsersLoaded(
            users: [body],
            page: requestedPage,
            size: requestedSize,
            totalCount: 1,
            totalPages: 1,
          ),
        );
        return;
      }

      emit(UsersError('HTTP ${resp.statusCode} ${resp.reasonPhrase}'));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> nextPage() async {
    final current = state;
    if (current is! UsersLoaded || current.page >= current.totalPages) return;
    await fetchUsers(page: current.page + 1, size: current.size);
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is! UsersLoaded || current.page <= 1) return;
    await fetchUsers(page: current.page - 1, size: current.size);
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

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
