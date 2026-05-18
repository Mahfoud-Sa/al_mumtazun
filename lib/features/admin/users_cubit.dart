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
  String? _currentSearch;
  bool? _currentIsActive;
  String? _currentRole;
  String _currentSortBy = 'id';
  String _currentSortDirection = 'asc';

  // ================= FETCH USERS =================

  Future<void> fetchUsers({
    int? page,
    int? size,
    String? search,
    bool? isActive,
    String? role,
    String? sortBy,
    String? sortDirection,
  }) async {
    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;
    final requestedSearch = search ?? _currentSearch;
    final requestedIsActive = isActive ?? _currentIsActive;
    final requestedRole = role ?? _currentRole;
    final requestedSortBy = sortBy ?? _currentSortBy;
    final requestedSortDirection = sortDirection ?? _currentSortDirection;

    emit(UsersLoading());

    try {
      final queryParameters = <String, String>{
        'page': requestedPage.toString(),
        'size': requestedSize.toString(),
        'sortBy': requestedSortBy,
        'sortDirection': requestedSortDirection,
      };
      if (requestedSearch != null && requestedSearch.trim().isNotEmpty) {
        queryParameters['search'] = requestedSearch.trim();
      }
      if (requestedIsActive != null) {
        queryParameters['isActive'] = requestedIsActive.toString();
      }
      if (requestedRole != null && requestedRole.trim().isNotEmpty) {
        queryParameters['role'] = requestedRole.trim();
      }

      final resp = await http.get(
        Uri.parse(baseUrl).replace(queryParameters: queryParameters),
        headers: {'accept': 'text/plain'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body);

        if (body is List) {
          _currentPage = requestedPage;
          _currentSize = requestedSize;
          _rememberQuery(
            search: requestedSearch,
            isActive: requestedIsActive,
            role: requestedRole,
            sortBy: requestedSortBy,
            sortDirection: requestedSortDirection,
          );
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
          _rememberQuery(
            search: requestedSearch,
            isActive: requestedIsActive,
            role: requestedRole,
            sortBy: requestedSortBy,
            sortDirection: requestedSortDirection,
          );

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
        _rememberQuery(
          search: requestedSearch,
          isActive: requestedIsActive,
          role: requestedRole,
          sortBy: requestedSortBy,
          sortDirection: requestedSortDirection,
        );
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

  Future<void> applyQuery({
    String? search,
    bool? isActive,
    String? role,
    int? size,
    String sortBy = 'id',
    String sortDirection = 'asc',
  }) async {
    _currentSearch = _blankToNull(search);
    _currentIsActive = isActive;
    _currentRole = _blankToNull(role);
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
    await fetchUsers(page: 1, size: size ?? _currentSize);
  }

  Future<void> clearQuery() async {
    _currentSearch = null;
    _currentIsActive = null;
    _currentRole = null;
    _currentSize = defaultPageSize;
    _currentSortBy = 'id';
    _currentSortDirection = 'asc';
    await fetchUsers(page: 1, size: defaultPageSize);
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

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _rememberQuery({
    required String? search,
    required bool? isActive,
    required String? role,
    required String sortBy,
    required String sortDirection,
  }) {
    _currentSearch = search;
    _currentIsActive = isActive;
    _currentRole = role;
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
  }
}
