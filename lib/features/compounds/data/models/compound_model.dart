import '../../domain/entities/compound.dart';

class CompoundModel extends Compound {
  const CompoundModel({
    required super.id,
    required super.name,
    super.description,
    required super.sellPrice,
    required super.quantity,
    required super.date,
  });

  factory CompoundModel.fromJson(Map<String, dynamic> json) {
    return CompoundModel(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sellPrice: _readDouble(json['sellPrice']),
      quantity: _readInt(json['quantity'] ?? json['Quantity']),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory CompoundModel.fromEntity(Compound compound) {
    return CompoundModel(
      id: compound.id,
      name: compound.name,
      description: compound.description,
      sellPrice: compound.sellPrice,
      quantity: compound.quantity,
      date: compound.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sellPrice': sellPrice,
      'quantity': quantity,
      'date': date.toIso8601String().split('T').first,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
