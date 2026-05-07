import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final String id;
  final String name;
  final List<String> permissions;

  const Role({required this.id, required this.name, this.permissions = const []});

  @override
  List<Object?> get props => [id, name, permissions];
}
