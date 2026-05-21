import 'package:engineering_ops_dashboard/core/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/role.dart';
import '../../domain/usecases/get_roles_usecase.dart';
import '../../domain/usecases/manage_role_usecases.dart';
import 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  final GetRolesUseCase getRoles;
  final CreateRoleUseCase createRole;
  final UpdateRoleUseCase updateRole;
  final DeleteRoleUseCase deleteRole;

  RolesCubit({
    required this.getRoles,
    required this.createRole,
    required this.updateRole,
    required this.deleteRole,
  }) : super(RolesInitial());

  Future<void> fetch() async {
    emit(RolesLoading());
    final res = await getRoles(NoParams());
    res.fold((l) => emit(RolesError(l.message)), (r) => emit(RolesLoaded(r)));
  }

  Future<bool> saveRole(Role role) async {
    final currentRoles = state is RolesLoaded
        ? (state as RolesLoaded).roles
        : const <Role>[];
    emit(RolesSaving(currentRoles));

    final exists = currentRoles.any((current) => current.id == role.id);
    final res = exists ? await updateRole(role) : await createRole(role);

    return res.fold(
      (failure) {
        emit(RolesError(failure.message));
        return false;
      },
      (_) async {
        await fetch();
        return true;
      },
    );
  }

  Future<bool> removeRole(int id) async {
    final currentRoles = state is RolesLoaded
        ? (state as RolesLoaded).roles
        : const <Role>[];
    emit(RolesSaving(currentRoles));

    final res = await deleteRole(id);
    return res.fold(
      (failure) {
        emit(RolesError(failure.message));
        return false;
      },
      (_) async {
        await fetch();
        return true;
      },
    );
  }
}
