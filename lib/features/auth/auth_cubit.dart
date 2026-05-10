import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<bool> {
  AuthCubit() : super(false);

  Future<void> login({String? email, String? password}) async {
    // TODO: replace with real auth logic.
    await Future.delayed(const Duration(milliseconds: 300));
    emit(true);
  }

  Future<void> logout() async {
    // TODO: perform logout cleanup if needed.
    await Future.delayed(const Duration(milliseconds: 100));
    emit(false);
  }
}
