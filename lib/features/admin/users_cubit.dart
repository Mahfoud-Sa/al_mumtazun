import 'dart:convert';

import 'package:engineering_ops_dashboard/core/clients/http_client.dart';
import 'package:engineering_ops_dashboard/core/models/paginated_response.dart';
import 'package:engineering_ops_dashboard/di/service_locator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_model.dart';

// ================= STATES =================

abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;
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
  UsersCubit({AppHttpClient? client})
    : client = client ?? getIt<AppHttpClient>(),
      super(UsersInitial());

  final AppHttpClient client;
  final String baseUrl = 'http://al-mumtazun-api.runasp.net/api/Users';
  static const int defaultPageSize = 10;

  int _currentPage = 1;
  int _currentSize = defaultPageSize;
  String? _currentSearch;
  bool? _currentIsActive;
  int? _currentRoleId;
  String _currentSortBy = 'id';
  String _currentSortDirection = 'asc';
  bool _isFetching = false;

  // ================= FETCH USERS =================

  Future<void> fetchUsers({
    int? page,
    int? size,
    String? search,
    bool? isActive,
    int? roleId,
    String? sortBy,
    String? sortDirection,
    bool append = false,
  }) async {
    if (_isFetching) return;

    final requestedPage = page ?? _currentPage;
    final requestedSize = size ?? _currentSize;
    final requestedSearch = search ?? _currentSearch;
    final requestedIsActive = isActive ?? _currentIsActive;
    final requestedRoleId = roleId ?? _currentRoleId;
    final requestedSortBy = sortBy ?? _currentSortBy;
    final requestedSortDirection = sortDirection ?? _currentSortDirection;
    final previous = append && state is UsersLoaded
        ? state as UsersLoaded
        : null;

    _isFetching = true;
    if (!append) emit(UsersLoading());

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
      if (requestedRoleId != null) {
        queryParameters['roleId'] = requestedRoleId.toString();
      }

      final resp = await client.get(
        Uri.parse(baseUrl).replace(queryParameters: queryParameters),
        headers: {'accept': 'text/plain'},
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body);

        if (body is List) {
          final users = body
              .whereType<Map<String, dynamic>>()
              .map(UserModel.fromJson)
              .toList();
          final loadedUsers = previous == null
              ? users
              : [...previous.users, ...users];
          _currentPage = requestedPage;
          _currentSize = requestedSize;
          _rememberQuery(
            search: requestedSearch,
            isActive: requestedIsActive,
            roleId: requestedRoleId,
            sortBy: requestedSortBy,
            sortDirection: requestedSortDirection,
          );
          emit(
            UsersLoaded(
              users: loadedUsers,
              page: requestedPage,
              size: requestedSize,
              totalCount: loadedUsers.length,
              totalPages: users.isEmpty ? 1 : 1,
            ),
          );
          return;
        }

        if (body is Map<String, dynamic> && body['data'] is List) {
          final page = PaginatedResponse<UserModel>.fromJson(
            body,
            UserModel.fromJson,
          );
          final loadedUsers = previous == null
              ? page.data
              : [...previous.users, ...page.data];

          _currentPage = page.page;
          _currentSize = page.size;
          _rememberQuery(
            search: requestedSearch,
            isActive: requestedIsActive,
            roleId: requestedRoleId,
            sortBy: requestedSortBy,
            sortDirection: requestedSortDirection,
          );

          emit(
            UsersLoaded(
              users: loadedUsers,
              page: page.page,
              size: page.size,
              totalCount: page.totalCount,
              totalPages: page.totalPages,
            ),
          );
          return;
        }

        _currentPage = requestedPage;
        _currentSize = requestedSize;
        final user = UserModel.fromJson(body as Map<String, dynamic>);
        final loadedUsers = previous == null
            ? [user]
            : [...previous.users, user];
        _rememberQuery(
          search: requestedSearch,
          isActive: requestedIsActive,
          roleId: requestedRoleId,
          sortBy: requestedSortBy,
          sortDirection: requestedSortDirection,
        );
        emit(
          UsersLoaded(
            users: loadedUsers,
            page: requestedPage,
            size: requestedSize,
            totalCount: loadedUsers.length,
            totalPages: 1,
          ),
        );
        return;
      }

      emit(UsersError('HTTP ${resp.statusCode} ${resp.reasonPhrase}'));
    } catch (e) {
      emit(UsersError(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> nextPage({bool append = false}) async {
    final current = state;
    if (current is! UsersLoaded || current.page >= current.totalPages) return;
    await fetchUsers(
      page: current.page + 1,
      size: current.size,
      append: append,
    );
  }

  Future<void> previousPage() async {
    final current = state;
    if (current is! UsersLoaded || current.page <= 1) return;
    await fetchUsers(page: current.page - 1, size: current.size);
  }

  Future<void> applyQuery({
    String? search,
    bool? isActive,
    int? roleId,
    int? size,
    String sortBy = 'id',
    String sortDirection = 'asc',
  }) async {
    _currentSearch = _blankToNull(search);
    _currentIsActive = isActive;
    _currentRoleId = roleId;
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
    await fetchUsers(page: 1, size: size ?? _currentSize);
  }

  Future<void> clearQuery() async {
    _currentSearch = null;
    _currentIsActive = null;
    _currentRoleId = null;
    _currentSize = defaultPageSize;
    _currentSortBy = 'id';
    _currentSortDirection = 'asc';
    await fetchUsers(page: 1, size: defaultPageSize);
  }

  // ================= ACTIVATE USER =================

  Future<bool> activateUser(int id) async {
    try {
      final resp = await client.post(
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
      final resp = await client.post(
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
      final resp = await client.put(
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

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _rememberQuery({
    required String? search,
    required bool? isActive,
    required int? roleId,
    required String sortBy,
    required String sortDirection,
  }) {
    _currentSearch = search;
    _currentIsActive = isActive;
    _currentRoleId = roleId;
    _currentSortBy = sortBy;
    _currentSortDirection = sortDirection;
  }
}
