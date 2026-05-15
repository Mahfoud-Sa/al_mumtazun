import '../../domain/entities/income_engineer.dart';

class IncomeEngineerModel extends IncomeEngineer {
  const IncomeEngineerModel({required super.id, required super.name});

  factory IncomeEngineerModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['userId'] ?? json['employeeId'];
    final id = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '') ?? 0;
    final name =
        json['fullName'] ??
        json['name'] ??
        json['username'] ??
        json['email'] ??
        'مستخدم $id';

    return IncomeEngineerModel(id: id, name: name.toString());
  }
}
