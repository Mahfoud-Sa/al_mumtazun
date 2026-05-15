import 'package:equatable/equatable.dart';

class IncomeEngineer extends Equatable {
  final int id;
  final String name;

  const IncomeEngineer({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
