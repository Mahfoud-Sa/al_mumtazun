import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../../../core/clients/http_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AppHttpClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    // Stubbed: replace with real network call
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(id: 'u1', name: 'Demo User', email: email, roles: ['user']);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(id: 'u${DateTime.now().millisecondsSinceEpoch}', name: name, email: email, roles: ['user']);
  }
}
