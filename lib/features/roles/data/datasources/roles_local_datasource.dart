import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/role_model.dart';

abstract class RolesLocalDataSource {
  Future<List<RoleModel>> getRoles();
  Future<void> saveRoles(List<RoleModel> roles);
}

class RolesLocalDataSourceImpl implements RolesLocalDataSource {
  static const _kRolesKey = 'cached_roles';
  final SharedPreferences prefs;

  RolesLocalDataSourceImpl(this.prefs);

  @override
  Future<List<RoleModel>> getRoles() async {
    final s = prefs.getString(_kRolesKey);
    if (s == null) return _defaultRoles;
    final list = (json.decode(s) as List<dynamic>);
    final roles = list
        .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return roles.isEmpty ? _defaultRoles : roles;
  }

  @override
  Future<void> saveRoles(List<RoleModel> roles) async {
    final s = json.encode(roles.map((r) => r.toJson()).toList());
    await prefs.setString(_kRolesKey, s);
  }

  static const _defaultRoles = [
    RoleModel(
      id: 1,
      name: 'Admin',
      permissions: [
        'dashboard.view',
        'devices.manage',
        'invoices.manage',
        'spare_parts.manage',
        'users.manage',
        'roles.manage',
        'profile.manage',
      ],
    ),
    RoleModel(
      id: 2,
      name: 'Engineer',
      permissions: [
        'dashboard.view',
        'devices.view',
        'devices.update_status',
        'devices.add_notes',
        'invoices.view',
        'spare_parts.view',
        'profile.manage',
      ],
    ),
    RoleModel(
      id: 3,
      name: 'Reception',
      permissions: [
        'dashboard.view',
        'devices.manage',
        'invoices.manage',
        'spare_parts.view',
        'profile.manage',
      ],
    ),
  ];
}
