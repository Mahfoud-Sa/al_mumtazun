import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/dashboard/state/dashboard_cubit.dart';
import '../features/home/state/home_cubit.dart';
import '../localization/locale_cubit.dart';
import '../localization/locale_repository.dart';
import '../theme/theme_cubit.dart';
import '../theme/theme_repository.dart';
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

// Compounds
import '../features/compounds/data/datasources/compounds_remote_datasource.dart';
import '../features/compounds/data/repositories/compound_repository_impl.dart';
import '../features/compounds/domain/repositories/compound_repository.dart';
import '../features/compounds/domain/usecases/create_compound_usecase.dart';
import '../features/compounds/domain/usecases/delete_compound_usecase.dart';
import '../features/compounds/domain/usecases/get_compounds_usecase.dart';
import '../features/compounds/domain/usecases/update_compound_usecase.dart';
import '../features/compounds/presentation/cubit/compounds_cubit.dart';

// Incomes
import '../features/incomes/data/datasources/incomes_remote_datasource.dart';
import '../features/incomes/data/repositories/income_repository_impl.dart';
import '../features/incomes/domain/repositories/income_repository.dart';
import '../features/incomes/domain/usecases/create_income_usecase.dart';
import '../features/incomes/domain/usecases/get_income_engineers_usecase.dart';
import '../features/incomes/presentation/cubit/incomes_cubit.dart';

// Invoices
import '../features/invoices/data/datasources/invoices_remote_datasource.dart';
import '../features/invoices/data/repositories/invoice_repository_impl.dart';
import '../features/invoices/domain/repositories/invoice_repository.dart';
import '../features/invoices/domain/usecases/create_invoice_usecase.dart';
import '../features/invoices/domain/usecases/get_invoice_by_device_usecase.dart';
import '../features/invoices/domain/usecases/get_invoices_usecase.dart';
import '../features/invoices/domain/usecases/update_invoice_usecase.dart';
import '../features/invoices/presentation/cubit/invoices_cubit.dart';

// Devices
import '../features/devices/data/datasources/device_users_remote_datasource.dart';
import '../features/devices/data/datasources/devices_remote_datasource.dart';
import '../features/devices/data/repositories/device_users_repository_impl.dart';
import '../features/devices/data/repositories/device_repository_impl.dart';
import '../features/devices/domain/entities/device.dart';
import '../features/devices/domain/repositories/device_users_repository.dart';
import '../features/devices/domain/repositories/device_repository.dart';
import '../features/devices/domain/usecases/change_device_status_usecase.dart';
import '../features/devices/domain/usecases/create_device_usecase.dart';
import '../features/devices/domain/usecases/get_device_users_usecase.dart';
import '../features/devices/domain/usecases/get_devices_usecase.dart';
import '../features/devices/domain/usecases/update_device_usecase.dart';
import '../features/devices/presentation/cubit/device_details_cubit.dart';
import '../features/devices/presentation/cubit/devices_cubit.dart';

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
import '../features/profile/data/datasources/profile_local_datasource.dart';
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/profile_usecases.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SharedPreferences>()) return;
  // Core
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocaleRepository>(LocaleRepository(prefs));
  getIt.registerSingleton<ThemeRepository>(ThemeRepository(prefs));

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

  // Compounds
  getIt.registerLazySingleton<CompoundsRemoteDataSource>(
    () => CompoundsRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<CompoundRepository>(
    () => CompoundRepositoryImpl(getIt<CompoundsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetCompoundsUseCase>(
    () => GetCompoundsUseCase(getIt<CompoundRepository>()),
  );
  getIt.registerLazySingleton<CreateCompoundUseCase>(
    () => CreateCompoundUseCase(getIt<CompoundRepository>()),
  );
  getIt.registerLazySingleton<UpdateCompoundUseCase>(
    () => UpdateCompoundUseCase(getIt<CompoundRepository>()),
  );
  getIt.registerLazySingleton<DeleteCompoundUseCase>(
    () => DeleteCompoundUseCase(getIt<CompoundRepository>()),
  );
  getIt.registerFactory<CompoundsCubit>(
    () => CompoundsCubit(
      getCompounds: getIt<GetCompoundsUseCase>(),
      createCompound: getIt<CreateCompoundUseCase>(),
      updateCompound: getIt<UpdateCompoundUseCase>(),
      deleteCompound: getIt<DeleteCompoundUseCase>(),
    ),
  );

  // Incomes
  getIt.registerLazySingleton<IncomesRemoteDataSource>(
    () => IncomesRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(getIt<IncomesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CreateIncomeUseCase>(
    () => CreateIncomeUseCase(getIt<IncomeRepository>()),
  );
  getIt.registerLazySingleton<GetIncomeEngineersUseCase>(
    () => GetIncomeEngineersUseCase(getIt<IncomeRepository>()),
  );
  getIt.registerFactory<IncomesCubit>(
    () => IncomesCubit(
      createIncome: getIt<CreateIncomeUseCase>(),
      getEngineers: getIt<GetIncomeEngineersUseCase>(),
    ),
  );

  // Invoices
  getIt.registerLazySingleton<InvoicesRemoteDataSource>(
    () => InvoicesRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(getIt<InvoicesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetInvoicesUseCase>(
    () => GetInvoicesUseCase(getIt<InvoiceRepository>()),
  );
  getIt.registerLazySingleton<GetInvoiceByDeviceUseCase>(
    () => GetInvoiceByDeviceUseCase(getIt<InvoiceRepository>()),
  );
  getIt.registerLazySingleton<CreateInvoiceUseCase>(
    () => CreateInvoiceUseCase(getIt<InvoiceRepository>()),
  );
  getIt.registerLazySingleton<UpdateInvoiceUseCase>(
    () => UpdateInvoiceUseCase(getIt<InvoiceRepository>()),
  );
  getIt.registerFactory<InvoicesCubit>(
    () => InvoicesCubit(getInvoices: getIt<GetInvoicesUseCase>()),
  );

  // Devices
  getIt.registerLazySingleton<DevicesRemoteDataSource>(
    () => DevicesRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<DeviceUsersRemoteDataSource>(
    () => DeviceUsersRemoteDataSourceImpl(getIt<AppHttpClient>()),
  );
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(getIt<DevicesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<DeviceUsersRepository>(
    () => DeviceUsersRepositoryImpl(getIt<DeviceUsersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetDevicesUseCase>(
    () => GetDevicesUseCase(getIt<DeviceRepository>()),
  );
  getIt.registerLazySingleton<CreateDeviceUseCase>(
    () => CreateDeviceUseCase(getIt<DeviceRepository>()),
  );
  getIt.registerLazySingleton<UpdateDeviceUseCase>(
    () => UpdateDeviceUseCase(getIt<DeviceRepository>()),
  );
  getIt.registerLazySingleton<ChangeDeviceStatusUseCase>(
    () => ChangeDeviceStatusUseCase(getIt<DeviceRepository>()),
  );
  getIt.registerLazySingleton<GetDeviceUsersUseCase>(
    () => GetDeviceUsersUseCase(getIt<DeviceUsersRepository>()),
  );
  getIt.registerFactory<DevicesCubit>(
    () => DevicesCubit(
      getDevices: getIt<GetDevicesUseCase>(),
      createDevice: getIt<CreateDeviceUseCase>(),
    ),
  );
  getIt.registerFactoryParam<DeviceDetailsCubit, Device, void>(
    (device, _) =>
        DeviceDetailsCubit(
            device,
            changeDeviceStatus: getIt<ChangeDeviceStatusUseCase>(),
            updateDevice: getIt<UpdateDeviceUseCase>(),
            getInvoiceByDevice: getIt<GetInvoiceByDeviceUseCase>(),
            createInvoice: getIt<CreateInvoiceUseCase>(),
            updateInvoice: getIt<UpdateInvoiceUseCase>(),
            getUsers: getIt<GetDeviceUsersUseCase>(),
          )
          ..loadUsers(refresh: true)
          ..loadInvoice(),
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
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      local: getIt<ProfileLocalDataSource>(),
      remote: getIt<ProfileRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetCurrentProfileUseCase>(
    () => GetCurrentProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<RefreshProfileUseCase>(
    () => RefreshProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileImageUrlUseCase>(
    () => UpdateProfileImageUrlUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getCurrentProfile: getIt<GetCurrentProfileUseCase>(),
      refreshProfileUseCase: getIt<RefreshProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      changePasswordUseCase: getIt<ChangePasswordUseCase>(),
      updateProfileImageUrlUseCase: getIt<UpdateProfileImageUrlUseCase>(),
    ),
  );
  getIt.registerFactory<LocaleCubit>(
    () => LocaleCubit(getIt<LocaleRepository>()),
  );
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt<ThemeRepository>()));
  getIt.registerFactory<HomeCubit>(() => HomeCubit());
  getIt.registerFactory<DashboardCubit>(() => DashboardCubit());
}
