import '../../domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({required String id, required String name, List<String> permissions = const []}) : super(id: id, name: name, permissions: permissions);

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      permissions: (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'permissions': permissions};
}
