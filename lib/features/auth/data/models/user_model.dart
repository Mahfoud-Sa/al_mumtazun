import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required String id, required String name, required String email, List<String> roles = const []}) : super(id: id, name: name, email: email, roles: roles);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'roles': roles,
      };
}
