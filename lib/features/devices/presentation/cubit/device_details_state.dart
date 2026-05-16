import 'package:equatable/equatable.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_user.dart';

class EngineerNote extends Equatable {
  final String author;
  final String text;
  final DateTime createdAt;

  const EngineerNote({
    required this.author,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [author, text, createdAt];
}

class BillComponent extends Equatable {
  final String name;
  final int quantity;
  final double price;

  const BillComponent({
    required this.name,
    required this.quantity,
    required this.price,
  });

  BillComponent copyWith({String? name, int? quantity, double? price}) {
    return BillComponent(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  double get total => quantity * price;

  @override
  List<Object?> get props => [name, quantity, price];
}

class ActivityLogEntry extends Equatable {
  final String title;
  final String description;
  final DateTime createdAt;
  final bool highlighted;

  const ActivityLogEntry({
    required this.title,
    required this.description,
    required this.createdAt,
    this.highlighted = false,
  });

  @override
  List<Object?> get props => [title, description, createdAt, highlighted];
}

class DeviceDetailsState extends Equatable {
  final Device device;
  final DeviceStatus status;
  final int? assignedEngineerId;
  final String assignedEngineer;
  final List<DeviceUser> users;
  final bool isLoadingUsers;
  final bool isLoadingMoreUsers;
  final int usersPage;
  final int usersPageSize;
  final int usersTotalPages;
  final bool hasReachedUsersEnd;
  final String? usersErrorMessage;
  final DateTime? deliveryDate;
  final String problemDescription;
  final String internalNotes;
  final List<EngineerNote> engineerNotes;
  final List<BillComponent> components;
  final double repairLaborPrice;
  final double additionalCosts;
  final double discount;
  final List<ActivityLogEntry> activityLog;
  final bool isChangingStatus;
  final String? statusErrorMessage;

  const DeviceDetailsState({
    required this.device,
    required this.status,
    required this.assignedEngineerId,
    required this.assignedEngineer,
    required this.users,
    required this.isLoadingUsers,
    required this.isLoadingMoreUsers,
    required this.usersPage,
    required this.usersPageSize,
    required this.usersTotalPages,
    required this.hasReachedUsersEnd,
    required this.usersErrorMessage,
    required this.deliveryDate,
    required this.problemDescription,
    required this.internalNotes,
    required this.engineerNotes,
    required this.components,
    required this.repairLaborPrice,
    required this.additionalCosts,
    required this.discount,
    required this.activityLog,
    required this.isChangingStatus,
    required this.statusErrorMessage,
  });

  factory DeviceDetailsState.initial(Device device) {
    final now = DateTime.now();
    return DeviceDetailsState(
      device: device,
      status: device.status,
      assignedEngineerId: null,
      assignedEngineer: device.receivedBy.isEmpty
          ? 'غير محدد'
          : device.receivedBy,
      users: const [],
      isLoadingUsers: false,
      isLoadingMoreUsers: false,
      usersPage: 0,
      usersPageSize: 10,
      usersTotalPages: 1,
      hasReachedUsersEnd: false,
      usersErrorMessage: null,
      deliveryDate: device.createdAt.add(const Duration(days: 14)),
      problemDescription: device.problemDescription,
      internalNotes: device.internalNotes,
      engineerNotes: [
        EngineerNote(
          author: 'سارة جنكنز',
          text:
              'تم إجراء فحص أولي للجهاز. يلزم استكمال التشخيص الفني قبل اعتماد قائمة القطع النهائية.',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ],
      components: const [
        BillComponent(name: 'طقم جلدة الصمام الرئيسي', quantity: 1, price: 245),
        BillComponent(name: 'زيت هيدروليك صناعي', quantity: 2, price: 60),
      ],
      repairLaborPrice: 450,
      additionalCosts: 45,
      discount: 0,
      isChangingStatus: false,
      statusErrorMessage: null,
      activityLog: [
        ActivityLogEntry(
          title: 'تم تحديث الحالة',
          description: 'تم نقل الجهاز إلى حالة الصيانة',
          createdAt: now.subtract(const Duration(hours: 3)),
          highlighted: true,
        ),
        ActivityLogEntry(
          title: 'تم تسجيل الجهاز',
          description: 'تم إنشاء سجل الاستلام في النظام',
          createdAt: device.createdAt,
        ),
      ],
    );
  }

  double get componentsTotal =>
      components.fold(0, (sum, component) => sum + component.total);

  double get subtotal => componentsTotal + repairLaborPrice + additionalCosts;

  double get totalBill {
    final total = subtotal - discount;
    return total < 0 ? 0 : total;
  }

  DeviceDetailsState copyWith({
    Device? device,
    DeviceStatus? status,
    int? assignedEngineerId,
    bool clearAssignedEngineerId = false,
    String? assignedEngineer,
    List<DeviceUser>? users,
    bool? isLoadingUsers,
    bool? isLoadingMoreUsers,
    int? usersPage,
    int? usersPageSize,
    int? usersTotalPages,
    bool? hasReachedUsersEnd,
    String? usersErrorMessage,
    bool clearUsersError = false,
    DateTime? deliveryDate,
    bool clearDeliveryDate = false,
    String? problemDescription,
    String? internalNotes,
    List<EngineerNote>? engineerNotes,
    List<BillComponent>? components,
    double? repairLaborPrice,
    double? additionalCosts,
    double? discount,
    List<ActivityLogEntry>? activityLog,
    bool? isChangingStatus,
    String? statusErrorMessage,
    bool clearStatusError = false,
  }) {
    return DeviceDetailsState(
      device: device ?? this.device,
      status: status ?? this.status,
      assignedEngineerId: clearAssignedEngineerId
          ? null
          : assignedEngineerId ?? this.assignedEngineerId,
      assignedEngineer: assignedEngineer ?? this.assignedEngineer,
      users: users ?? this.users,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      isLoadingMoreUsers: isLoadingMoreUsers ?? this.isLoadingMoreUsers,
      usersPage: usersPage ?? this.usersPage,
      usersPageSize: usersPageSize ?? this.usersPageSize,
      usersTotalPages: usersTotalPages ?? this.usersTotalPages,
      hasReachedUsersEnd: hasReachedUsersEnd ?? this.hasReachedUsersEnd,
      usersErrorMessage: clearUsersError
          ? null
          : usersErrorMessage ?? this.usersErrorMessage,
      deliveryDate: clearDeliveryDate
          ? null
          : deliveryDate ?? this.deliveryDate,
      problemDescription: problemDescription ?? this.problemDescription,
      internalNotes: internalNotes ?? this.internalNotes,
      engineerNotes: engineerNotes ?? this.engineerNotes,
      components: components ?? this.components,
      repairLaborPrice: repairLaborPrice ?? this.repairLaborPrice,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      discount: discount ?? this.discount,
      activityLog: activityLog ?? this.activityLog,
      isChangingStatus: isChangingStatus ?? this.isChangingStatus,
      statusErrorMessage: clearStatusError
          ? null
          : statusErrorMessage ?? this.statusErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    device,
    status,
    assignedEngineerId,
    assignedEngineer,
    users,
    isLoadingUsers,
    isLoadingMoreUsers,
    usersPage,
    usersPageSize,
    usersTotalPages,
    hasReachedUsersEnd,
    usersErrorMessage,
    deliveryDate,
    problemDescription,
    internalNotes,
    engineerNotes,
    components,
    repairLaborPrice,
    additionalCosts,
    discount,
    activityLog,
    isChangingStatus,
    statusErrorMessage,
  ];
}
