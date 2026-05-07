import '../../domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({required String id, required String name, String? description, int quantity = 0}) : super(id: id, name: name, description: description, quantity: quantity);

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'quantity': quantity};
}
