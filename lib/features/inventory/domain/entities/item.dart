import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int quantity;

  const Item({required this.id, required this.name, this.description, this.quantity = 0});

  Item copyWith({String? id, String? name, String? description, int? quantity}) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, description, quantity];
}
