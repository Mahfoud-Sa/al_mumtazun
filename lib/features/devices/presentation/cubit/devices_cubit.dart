import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/device.dart';
import '../../domain/usecases/create_device_usecase.dart';
import '../../domain/usecases/get_devices_usecase.dart';
import 'devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final GetDevicesUseCase getDevices;
  final CreateDeviceUseCase createDevice;
  static const int defaultPageSize = 10;

  DevicesCubit({required this.getDevices, required this.createDevice})
    : super(const DevicesState());

  Future<void> fetch({bool refresh = false}) async {
    emit(
      state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        page: refresh ? 0 : state.page,
        hasReachedEnd: false,
        clearError: true,
      ),
    );
    final result = await getDevices(
      GetDevicesParams(
        page: 1,
        size: defaultPageSize,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      ),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (devicePage) {
        final devices = devicePage.devices;
        emit(
          state.copyWith(
            devices: devices,
            visibleDevices: _applyFilters(
              devices: devices,
              query: state.searchQuery,
              statusFilter: state.statusFilter,
              sortBy: state.sortBy,
              sortDirection: state.sortDirection,
            ),
            isLoading: false,
            page: devicePage.page,
            size: devicePage.size,
            totalCount: devicePage.totalCount,
            totalPages: devicePage.totalPages,
            hasReachedEnd:
                devicePage.page >= devicePage.totalPages ||
                devicePage.devices.length < devicePage.size,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        state.hasReachedEnd ||
        state.page <= 0) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    final result = await getDevices(
      GetDevicesParams(
        page: nextPage,
        size: state.size,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
      (devicePage) {
        final devices = [...state.devices, ...devicePage.devices];
        emit(
          state.copyWith(
            devices: devices,
            visibleDevices: _applyFilters(
              devices: devices,
              query: state.searchQuery,
              statusFilter: state.statusFilter,
              sortBy: state.sortBy,
              sortDirection: state.sortDirection,
            ),
            isLoadingMore: false,
            page: devicePage.page,
            size: devicePage.size,
            totalCount: devicePage.totalCount,
            totalPages: devicePage.totalPages,
            hasReachedEnd:
                devicePage.page >= devicePage.totalPages ||
                devicePage.devices.length < devicePage.size,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> goToPage(int page) {
    final target = page.clamp(1, state.totalPages);
    return _fetchExactPage(target);
  }

  Future<void> previousPage() {
    return goToPage(state.page - 1);
  }

  Future<void> nextPage() {
    return goToPage(state.page + 1);
  }

  void updateSearch(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        visibleDevices: _applyFilters(
          devices: state.devices,
          query: query,
          statusFilter: state.statusFilter,
          sortBy: state.sortBy,
          sortDirection: state.sortDirection,
        ),
      ),
    );
  }

  void setStatusFilter(DeviceStatus? status) {
    emit(
      state.copyWith(
        statusFilter: status,
        clearStatusFilter: status == null,
        visibleDevices: _applyFilters(
          devices: state.devices,
          query: state.searchQuery,
          statusFilter: status,
          sortBy: state.sortBy,
          sortDirection: state.sortDirection,
        ),
      ),
    );
  }

  Future<void> updateSorting(String sortBy, String sortDirection) {
    emit(
      state.copyWith(
        sortBy: sortBy,
        sortDirection: sortDirection,
        visibleDevices: _applyFilters(
          devices: state.devices,
          query: state.searchQuery,
          statusFilter: state.statusFilter,
          sortBy: sortBy,
          sortDirection: sortDirection,
        ),
      ),
    );
    return fetch(refresh: true);
  }

  Future<bool> addDevice(Device device) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        submitSucceeded: false,
        clearError: true,
      ),
    );
    final result = await createDevice(device);
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
            submitSucceeded: false,
          ),
        );
        return false;
      },
      (_) async {
        await fetch(refresh: true);
        emit(state.copyWith(isSubmitting: false, submitSucceeded: true));
        return true;
      },
    );
  }

  void clearSubmitFlag() {
    emit(state.copyWith(submitSucceeded: false));
  }

  Future<void> _fetchExactPage(int page) async {
    if (state.isLoading || state.isLoadingMore) return;

    emit(
      state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        hasReachedEnd: false,
        clearError: true,
      ),
    );
    final result = await getDevices(
      GetDevicesParams(
        page: page,
        size: state.size,
        sortBy: state.sortBy,
        sortDirection: state.sortDirection,
      ),
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (devicePage) {
        final devices = devicePage.devices;
        emit(
          state.copyWith(
            devices: devices,
            visibleDevices: _applyFilters(
              devices: devices,
              query: state.searchQuery,
              statusFilter: state.statusFilter,
              sortBy: state.sortBy,
              sortDirection: state.sortDirection,
            ),
            isLoading: false,
            page: devicePage.page,
            size: devicePage.size,
            totalCount: devicePage.totalCount,
            totalPages: devicePage.totalPages,
            hasReachedEnd:
                devicePage.page >= devicePage.totalPages ||
                devicePage.devices.length < devicePage.size,
            clearError: true,
          ),
        );
      },
    );
  }

  List<Device> _applyFilters({
    required List<Device> devices,
    required String query,
    required DeviceStatus? statusFilter,
    required String sortBy,
    required String sortDirection,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = devices.where((device) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          device.name.toLowerCase().contains(normalizedQuery) ||
          device.customerName.toLowerCase().contains(normalizedQuery) ||
          device.brand.toLowerCase().contains(normalizedQuery) ||
          device.serialNumber.toLowerCase().contains(normalizedQuery);
      final matchesStatus =
          statusFilter == null || device.status == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      final result = switch (sortBy) {
        'name' => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        'status' => a.status.index.compareTo(b.status.index),
        'date' => a.createdAt.compareTo(b.createdAt),
        _ => _compareDeviceIds(a.id, b.id),
      };
      return sortDirection == 'desc' ? -result : result;
    });
    return filtered;
  }

  int _compareDeviceIds(String left, String right) {
    final leftNumber = int.tryParse(left);
    final rightNumber = int.tryParse(right);
    if (leftNumber != null && rightNumber != null) {
      return leftNumber.compareTo(rightNumber);
    }
    return left.compareTo(right);
  }
}
