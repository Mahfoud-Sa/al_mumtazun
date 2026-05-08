import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

// Simple users state classes using Equatable for easy comparisons
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

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  final Uri _uri = Uri.parse('http://al-mumtazun-api.runasp.net/api/Users');

  Future<void> fetchUsers() async {
    emit(UsersLoading());
    try {
      final resp = await http.get(_uri, headers: {'accept': 'text/plain'});
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
}
