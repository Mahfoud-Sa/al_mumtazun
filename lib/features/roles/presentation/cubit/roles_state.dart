import 'package:equatable/equatable.dart';
import '../../domain/entities/role.dart';

abstract class RolesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RolesInitial extends RolesState {}
class RolesLoading extends RolesState {}
class RolesLoaded extends RolesState {
  final List<Role> roles;
  RolesLoaded(this.roles);
  @override
  List<Object?> get props => [roles];
}

class RolesError extends RolesState {
  final String message;
  RolesError(this.message);
  @override
  List<Object?> get props => [message];
}
