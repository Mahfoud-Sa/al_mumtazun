class UserModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? address;
  final DateTime? birthDay;
  final DateTime? employeDate;
  final int roleId;
  final String roleName;
  final bool isActive;
  final double salary;
  final double workPercentage;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.address,
    this.birthDay,
    this.employeDate,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.salary,
    required this.workPercentage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _readInt(json['id'] ?? json['userId']),
      fullName: _readString(json['fullName'] ?? json['name']),
      phoneNumber: _readString(json['phoneNumber']),
      address: _readNullableString(json['address']),
      birthDay: _readDate(json['birthDay']),
      employeDate: _readDate(json['employeDate']),
      roleId: _readInt(json['roleId']),
      roleName: _readString(json['role'] ?? json['roleName']),
      isActive: _readBool(json['isActive']),
      salary: _readDouble(json['salary']),
      workPercentage: _readDouble(json['workPercentage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'address': address,
    'birthDay': birthDay?.toIso8601String(),
    'employeDate': employeDate?.toIso8601String(),
    'roleId': roleId,
    'role': roleName,
    'isActive': isActive,
    'salary': salary,
    'workPercentage': workPercentage,
  };

  static int _readInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static String _readString(dynamic value) => value?.toString() ?? '';

  static String? _readNullableString(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) return null;
    return text;
  }

  static DateTime? _readDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
