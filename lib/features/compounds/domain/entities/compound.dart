import 'package:equatable/equatable.dart';

class Compound extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double cellPrice;
  final DateTime date;

  const Compound({
    required this.id,
    required this.name,
    this.description,
    required this.cellPrice,
    required this.date,
  });

  Compound copyWith({
    int? id,
    String? name,
    String? description,
    double? cellPrice,
    DateTime? date,
  }) {
    return Compound(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cellPrice: cellPrice ?? this.cellPrice,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, name, description, cellPrice, date];
}
