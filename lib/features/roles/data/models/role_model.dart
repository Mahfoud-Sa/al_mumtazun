import '../../domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
    super.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
    );
  }

  factory RoleModel.fromEntity(Role role) {
    return RoleModel(
      id: role.id,
      name: role.name,
      permissions: role.permissions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'permissions': permissions,
  };
}
