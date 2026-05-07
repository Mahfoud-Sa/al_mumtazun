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
}
