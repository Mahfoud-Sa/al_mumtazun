import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_user.dart';
import '../../domain/usecases/change_device_status_usecase.dart';
import '../../domain/usecases/get_device_users_usecase.dart';
import '../../domain/usecases/update_device_usecase.dart';
import '../../../invoices/domain/entities/invoice.dart';
import '../../../invoices/domain/entities/invoice_item.dart';
import '../../../invoices/domain/usecases/create_invoice_usecase.dart';
import 'device_details_state.dart';

class DeviceDetailsCubit extends Cubit<DeviceDetailsState> {
  final ChangeDeviceStatusUseCase changeDeviceStatus;
  final UpdateDeviceUseCase updateDevice;
  final CreateInvoiceUseCase createInvoice;
  final GetDeviceUsersUseCase getUsers;
  static const int defaultUsersPageSize = 10;

  DeviceDetailsCubit(
    Device device, {
    required this.changeDeviceStatus,
    required this.updateDevice,
    required this.createInvoice,
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

  Future<void> exportInvoice() async {
    if (state.isCreatingInvoice) return;

    final deviceId = int.tryParse(state.device.id);
    if (deviceId == null) {
      emit(
        state.copyWith(
          invoiceErrorMessage: 'لا يمكن إنشاء الفاتورة قبل تحديث بيانات الجهاز',
          invoiceCreated: false,
        ),
      );
      return;
    }

    final invoiceItems = _invoiceItemsForSubmission();
    if (invoiceItems.isEmpty) {
      emit(
        state.copyWith(
          invoiceErrorMessage: 'أضف عنصرًا واحدًا على الأقل قبل تصدير الفاتورة',
          invoiceCreated: false,
        ),
      );
      return;
    }

    final invoice = Invoice(
      id: 0,
      deviceId: deviceId,
      device: state.device,
      customerId: 0,
      date: DateTime.now(),
      discount: state.discount,
      items: invoiceItems,
    );

    emit(
      state.copyWith(
        isCreatingInvoice: true,
        clearInvoiceError: true,
        invoiceCreated: false,
      ),
    );

    final result = await createInvoice(CreateInvoiceParams(invoice: invoice));

    result.fold(
      (failure) => emit(
        state.copyWith(
          isCreatingInvoice: false,
          invoiceErrorMessage: failure.message,
          invoiceCreated: false,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isCreatingInvoice: false,
          clearInvoiceError: true,
          invoiceCreated: true,
        ),
      ),
    );
  }

  void addInvoiceItem(InvoiceItem item) {
    final existingIndex = state.invoiceItems.indexWhere(
      (current) =>
          current.sparePartId == item.sparePartId &&
          current.sparePartName == item.sparePartName &&
          current.unitPrice == item.unitPrice,
    );

    if (existingIndex == -1) {
      emit(state.copyWith(invoiceItems: [...state.invoiceItems, item]));
      return;
    }

    final invoiceItems = [...state.invoiceItems];
    final existing = invoiceItems[existingIndex];
    invoiceItems[existingIndex] = existing.copyWith(
      quantity: existing.quantity + item.quantity,
    );
    emit(state.copyWith(invoiceItems: invoiceItems));
  }

  void updateInvoiceItemQuantity(int index, int quantity) {
    if (index < 0 || index >= state.invoiceItems.length) return;

    if (quantity <= 0) {
      removeInvoiceItem(index);
      return;
    }

    final invoiceItems = [...state.invoiceItems];
    invoiceItems[index] = invoiceItems[index].copyWith(quantity: quantity);
    emit(state.copyWith(invoiceItems: invoiceItems));
  }

  void removeInvoiceItem(int index) {
    if (index < 0 || index >= state.invoiceItems.length) return;

    final invoiceItems = [...state.invoiceItems]..removeAt(index);
    emit(state.copyWith(invoiceItems: invoiceItems));
  }

  List<InvoiceItem> _invoiceItemsForSubmission() {
    final items = <InvoiceItem>[...state.invoiceItems];
    if (state.repairLaborPrice > 0) {
      items.add(
        InvoiceItem(
          id: 0,
          invoiceId: 0,
          sparePartId: null,
          sparePartName: 'أجرة الصيانة',
          quantity: 1,
          unitPrice: state.repairLaborPrice,
        ),
      );
    }
    if (state.additionalCosts > 0) {
      items.add(
        InvoiceItem(
          id: 0,
          invoiceId: 0,
          sparePartId: null,
          sparePartName: 'تكاليف إضافية',
          quantity: 1,
          unitPrice: state.additionalCosts,
        ),
      );
    }
    return items;
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
