import 'package:equatable/equatable.dart';

class Compound extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double sellPrice;
  final DateTime date;

  const Compound({
    required this.id,
    required this.name,
    this.description,
    required this.sellPrice,
    required this.date,
  });

  Compound copyWith({
    int? id,
    String? name,
    String? description,
    double? sellPrice,
    DateTime? date,
  }) {
    return Compound(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, name, description, sellPrice, date];
}
