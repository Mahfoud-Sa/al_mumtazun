import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_user.dart';
import '../../domain/usecases/change_device_status_usecase.dart';
import '../../domain/usecases/get_device_users_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';
import 'device_details_state.dart';

class DeviceDetailsCubit extends Cubit<DeviceDetailsState> {
  final ChangeDeviceStatusUseCase changeDeviceStatus;
  final UpdateDeviceUseCase updateDevice;
  final GetDeviceUsersUseCase getUsers;
  static const int defaultUsersPageSize = 10;

  DeviceDetailsCubit(
    Device device, {
    required this.changeDeviceStatus,
    required this.updateDevice,
    required this.getUsers,
  }) : super(DeviceDetailsState.initial(device));

  Future<void> loadUsers({bool refresh = false}) async {
    if (state.isLoadingUsers || state.isLoadingMoreUsers) return;

    emit(
      state.copyWith(
        isLoadingUsers: refresh || state.users.isEmpty,
        isLoadingMoreUsers: !refresh && state.users.isNotEmpty,
        usersPage: refresh ? 0 : state.usersPage,
        hasReachedUsersEnd: refresh ? false : state.hasReachedUsersEnd,
        clearUsersError: true,
      ),
    );

    final requestedPage = refresh || state.usersPage == 0
        ? 1
        : state.usersPage + 1;
    final result = await getUsers(
      GetDeviceUsersParams(
        page: requestedPage,
        size: state.usersPageSize == 0
            ? defaultUsersPageSize
            : state.usersPageSize,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingUsers: false,
          isLoadingMoreUsers: false,
          usersErrorMessage: failure.message,
        ),
      ),
      (usersPage) {
        final users = refresh || state.usersPage == 0
            ? usersPage.users
            : [...state.users, ...usersPage.users];
        emit(
          state.copyWith(
            users: users,
            isLoadingUsers: false,
            isLoadingMoreUsers: false,
            usersPage: usersPage.page,
            usersPageSize: usersPage.size,
            usersTotalPages: usersPage.totalPages,
            hasReachedUsersEnd:
                usersPage.page >= usersPage.totalPages ||
                usersPage.users.length < usersPage.size,
            clearUsersError: true,
          ),
        );
      },
    );
  }

  Future<void> changeStatus(DeviceStatus status) async {
    if (state.isChangingStatus || status == state.status) return;

    final previousStatus = state.status;
    final previousActivityLog = state.activityLog;
    emit(
      state.copyWith(
        status: status,
        device: state.device.copyWith(status: status),
        isChangingStatus: true,
        clearStatusError: true,
        activityLog: [
          ActivityLogEntry(
            title: 'تم تحديث الحالة',
            description: 'تم تغيير الحالة إلى ${_statusLabel(status)}',
            createdAt: DateTime.now(),
            highlighted: true,
          ),
          ...state.activityLog,
        ],
      ),
    );

    final result = await changeDeviceStatus(
      ChangeDeviceStatusParams(id: state.device.id, status: status),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: previousStatus,
          device: state.device.copyWith(status: previousStatus),
          isChangingStatus: false,
          statusErrorMessage: failure.message,
          activityLog: previousActivityLog,
        ),
      ),
      (_) => emit(state.copyWith(isChangingStatus: false)),
    );
  }

  void assignEngineer(DeviceUser engineer) {
    emit(
      state.copyWith(
        assignedEngineerId: engineer.id,
        assignedEngineer: engineer.name,
      ),
    );
  }

  void updateDeliveryDate(DateTime? date) {
    emit(state.copyWith(deliveryDate: date, clearDeliveryDate: date == null));
  }

  void updateProblemDescription(String value) {
    emit(state.copyWith(problemDescription: value));
  }

  void updateInternalNotes(String value) {
    emit(state.copyWith(internalNotes: value));
  }

  void updateRepairLaborPrice(String value) {
    emit(state.copyWith(repairLaborPrice: double.tryParse(value) ?? 0));
  }

  void updateAdditionalCosts(String value) {
    emit(state.copyWith(additionalCosts: double.tryParse(value) ?? 0));
  }

  void updateDiscount(String value) {
    final discount = double.tryParse(value) ?? 0;
    emit(state.copyWith(discount: discount < 0 ? 0 : discount));
  }

  Future<void> addEngineerNote(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSavingEngineerNote) return;

    final previousDevice = state.device;
    final updatedDevice = state.device.copyWith(engineerNote: trimmed);
    emit(
      state.copyWith(
        device: updatedDevice,
        isSavingEngineerNote: true,
        clearEngineerNoteError: true,
      ),
    );

    final result = await updateDevice(
      UpdateDeviceParams(device: updatedDevice),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          device: previousDevice,
          isSavingEngineerNote: false,
          engineerNoteErrorMessage: failure.message,
        ),
      ),
      (device) =>
          emit(state.copyWith(device: device, isSavingEngineerNote: false)),
    );
  }

  void addComponent(BillComponent component) {
    final existingIndex = state.components.indexWhere(
      (item) => item.name == component.name && item.price == component.price,
    );

    if (existingIndex == -1) {
      emit(state.copyWith(components: [...state.components, component]));
      return;
    }

    final components = [...state.components];
    final existing = components[existingIndex];
    components[existingIndex] = existing.copyWith(
      quantity: existing.quantity + component.quantity,
    );
    emit(state.copyWith(components: components));
  }

  void updateComponentQuantity(int index, int quantity) {
    if (index < 0 || index >= state.components.length) return;

    if (quantity <= 0) {
      removeComponent(index);
      return;
    }

    final components = [...state.components];
    components[index] = components[index].copyWith(quantity: quantity);
    emit(state.copyWith(components: components));
  }

  void removeComponent(int index) {
    if (index < 0 || index >= state.components.length) return;

    final components = [...state.components]..removeAt(index);
    emit(state.copyWith(components: components));
  }

  String _statusLabel(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.received:
        return 'استلام';
      case DeviceStatus.waiting:
        return 'انتظار';
      case DeviceStatus.inMaintenance:
        return 'قيد الصيانة';
      case DeviceStatus.completed:
        return 'تم';
      case DeviceStatus.delivered:
        return 'تم تسليم العميل';
    }
  }
}
