import 'package:equatable/equatable.dart';

import '../../domain/entities/device.dart';

class DevicesState extends Equatable {
  final List<Device> devices;
  final List<Device> visibleDevices;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String searchQuery;
  final DeviceStatus? statusFilter;
  final bool sortNewestFirst;
  final int page;
  final int size;
  final int totalCount;
  final int totalPages;
  final bool hasReachedEnd;
  final String? errorMessage;
  final bool submitSucceeded;

  const DevicesState({
    this.devices = const [],
    this.visibleDevices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.searchQuery = '',
    this.statusFilter,
    this.sortNewestFirst = true,
    this.page = 0,
    this.size = 10,
    this.totalCount = 0,
    this.totalPages = 1,
    this.hasReachedEnd = false,
    this.errorMessage,
    this.submitSucceeded = false,
  });

  DevicesState copyWith({
    List<Device>? devices,
    List<Device>? visibleDevices,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    String? searchQuery,
    DeviceStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? sortNewestFirst,
    int? page,
    int? size,
    int? totalCount,
    int? totalPages,
    bool? hasReachedEnd,
    String? errorMessage,
    bool clearError = false,
    bool? submitSucceeded,
  }) {
    return DevicesState(
      devices: devices ?? this.devices,
      visibleDevices: visibleDevices ?? this.visibleDevices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : statusFilter ?? this.statusFilter,
      sortNewestFirst: sortNewestFirst ?? this.sortNewestFirst,
      page: page ?? this.page,
      size: size ?? this.size,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }

  @override
  List<Object?> get props => [
    devices,
    visibleDevices,
    isLoading,
    isLoadingMore,
    isSubmitting,
    searchQuery,
    statusFilter,
    sortNewestFirst,
    page,
    size,
    totalCount,
    totalPages,
    hasReachedEnd,
    errorMessage,
    submitSucceeded,
  ];
}
