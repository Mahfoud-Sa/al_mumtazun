import '../../domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
    super.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: _readInt(json['id']),
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

  static int _readInt(dynamic value) {
    if (value is int) return value;
    final text = value?.toString() ?? '';
    final parsed = int.tryParse(text);
    if (parsed != null) return parsed;
    switch (text.trim().toLowerCase()) {
      case 'admin':
        return 1;
      case 'engineer':
        return 2;
      case 'reception':
        return 3;
    }
    return 0;
  }
}
