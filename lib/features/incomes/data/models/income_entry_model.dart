import '../../domain/entities/income_entry.dart';

class IncomeEntryModel extends IncomeEntry {
  const IncomeEntryModel({
    required super.price,
    required super.date,
    required super.description,
    required super.item,
    required super.engineerId,
  });

  factory IncomeEntryModel.fromEntity(IncomeEntry entry) {
    return IncomeEntryModel(
      price: entry.price,
      date: entry.date,
      description: entry.description,
      item: entry.item,
      engineerId: entry.engineerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'date': date.toUtc().toIso8601String(),
      'description': description,
      'item': item,
      'engineerId': engineerId,
    };
  }
}
