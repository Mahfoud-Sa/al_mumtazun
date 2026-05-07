import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/dashboard/state/dashboard_cubit.dart';
import '../features/home/state/home_cubit.dart';
import '../localization/locale_cubit.dart';
import '../localization/locale_repository.dart';
import '../core/clients/http_client.dart';

// Auth
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/user_repository_impl.dart';
import '../features/auth/domain/repositories/user_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

// Roles
import '../features/roles/data/datasources/roles_local_datasource.dart';
import '../features/roles/data/repositories/role_repository_impl.dart';
import '../features/roles/domain/repositories/role_repository.dart';
import '../features/roles/domain/usecases/get_roles_usecase.dart';
import '../features/roles/domain/usecases/manage_role_usecases.dart';
import '../features/roles/presentation/cubit/roles_cubit.dart';

// Inventory
import '../features/inventory/data/datasources/inventory_local_datasource.dart';
import '../features/inventory/data/repositories/item_repository_impl.dart';
import '../features/inventory/domain/repositories/item_repository.dart';
import '../features/inventory/domain/usecases/manage_items_usecases.dart';
import '../features/inventory/presentation/cubit/inventory_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) return;
  // Core
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocaleRepository>(LocaleRepository(prefs));

  // Core clients
  getIt.registerLazySingleton<AppHttpClient>(() => AppHttpClient());

  // Auth
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      local: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // Roles
  getIt.registerLazySingleton<RolesLocalDataSource>(
    () => RolesLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<RoleRepository>(
    () => RoleRepositoryImpl(getIt<RolesLocalDataSource>()),
  );
  getIt.registerLazySingleton<GetRolesUseCase>(
    () => GetRolesUseCase(getIt<RoleRepository>()),
  );
  getIt.registerLazySingleton<CreateRoleUseCase>(
    () => CreateRoleUseCase(getIt<RoleRepository>()),
  );
  getIt.registerLazySingleton<UpdateRoleUseCase>(
    () => UpdateRoleUseCase(getIt<RoleRepository>()),
  );
  getIt.registerLazySingleton<DeleteRoleUseCase>(
    () => DeleteRoleUseCase(getIt<RoleRepository>()),
  );
  getIt.registerFactory<RolesCubit>(
    () => RolesCubit(
      getRoles: getIt<GetRolesUseCase>(),
      createRole: getIt<CreateRoleUseCase>(),
      updateRole: getIt<UpdateRoleUseCase>(),
      deleteRole: getIt<DeleteRoleUseCase>(),
    ),
  );

  // Inventory
  getIt.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ItemRepository>(
    () => ItemRepositoryImpl(getIt<InventoryLocalDataSource>()),
  );
  getIt.registerLazySingleton<GetItemsUseCase>(
    () => GetItemsUseCase(getIt<ItemRepository>()),
  );
  getIt.registerLazySingleton<CreateItemUseCase>(
    () => CreateItemUseCase(getIt<ItemRepository>()),
  );
  getIt.registerLazySingleton<UpdateItemUseCase>(
    () => UpdateItemUseCase(getIt<ItemRepository>()),
  );
  getIt.registerLazySingleton<DeleteItemUseCase>(
    () => DeleteItemUseCase(getIt<ItemRepository>()),
  );
  // getIt.registerFactory<InventoryCubit>(
  //   () => InventoryCubit(
  //     getItems: getIt<GetItemsUseCase>(),
  //     createItem: getIt<CreateItemUseCase>(),
  //   ),
  // );

  // Cubits (factories so they can be recreated if needed)
  getIt.registerFactory<LocaleCubit>(
    () => LocaleCubit(getIt<LocaleRepository>()),
  );
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit());
}
