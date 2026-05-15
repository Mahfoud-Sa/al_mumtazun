import 'package:equatable/equatable.dart';

class IncomeEntry extends Equatable {
  final double price;
  final DateTime date;
  final String description;
  final String item;
  final int engineerId;

  const IncomeEntry({
    required this.price,
    required this.date,
    required this.description,
    required this.item,
    required this.engineerId,
  });

  @override
  List<Object?> get props => [price, date, description, item, engineerId];
}
