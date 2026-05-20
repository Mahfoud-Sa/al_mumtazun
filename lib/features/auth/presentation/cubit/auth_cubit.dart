import 'package:engineering_ops_dashboard/core/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final res = await loginUseCase(LoginParams(email, password));
    res.fold(
      (l) => emit(AuthError(l.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final res = await logoutUseCase(NoParams());
    res.fold(
      (l) => emit(AuthError(l.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> loadCurrent() async {
    emit(AuthLoading());
    final res = await getCurrentUserUseCase(NoParams());
    res.fold(
      (l) => emit(AuthError(l.message)),
      (user) => user == null
          ? emit(AuthUnauthenticated())
          : emit(AuthAuthenticated(user)),
    );
  }
}
