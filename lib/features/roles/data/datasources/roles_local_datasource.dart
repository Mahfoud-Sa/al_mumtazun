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
    if (s == null) return [];
    final list = (json.decode(s) as List<dynamic>);
    return list
        .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRoles(List<RoleModel> roles) async {
    final s = json.encode(roles.map((r) => r.toJson()).toList());
    await prefs.setString(_kRolesKey, s);
  }
}
