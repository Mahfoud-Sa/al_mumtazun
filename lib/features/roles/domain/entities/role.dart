import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final int id;
  final String name;
  final List<String> permissions;

  const Role({
    required this.id,
    required this.name,
    this.permissions = const [],
  });

  Role copyWith({int? id, String? name, List<String>? permissions}) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [id, name, permissions];
}
