import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<ItemModel>> getItems();
  Future<void> saveItems(List<ItemModel> items);
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  static const _kItemsKey = 'cached_items';
  final SharedPreferences prefs;

  InventoryLocalDataSourceImpl(this.prefs);

  @override
  Future<List<ItemModel>> getItems() async {
    final s = prefs.getString(_kItemsKey);
    if (s == null) return [];
    final list = (json.decode(s) as List<dynamic>);
    return list
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveItems(List<ItemModel> items) async {
    final s = json.encode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_kItemsKey, s);
  }
}
