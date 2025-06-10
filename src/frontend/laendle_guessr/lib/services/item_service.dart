import 'package:laendle_guessr/services/api_service.dart';
import 'dart:convert';
import 'package:laendle_guessr/data_objects/item.dart';

class ItemService {
  final ApiService api;

  ItemService(this.api);

  Future<List<Item>> getAllItems() async {
    final response = await api.get('all_items_get');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((jsonItem) => Item.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Fehler beim Laden aller Items: ${response.statusCode}');
    }
  }
  Future<List<Item>> getAllItemsByUser(int userId) async {
    final response = await api.get('all_items_owned_by/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((jsonItem) => Item.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Fehler beim Laden aller Items eines Users: ${response.statusCode}');
    }
  }

  Future<Item> getItemById(int itemId) async {
    final response = await api.get('item_get/$itemId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Item.fromJson(json);
    } else {
      throw Exception('Fehler beim Laden des Items: ${response.statusCode}');
    }
  }
  Future<void> addItemToInventory(int userId, Item item) async {
    final response = await api.post('add_item_to_inventory', {
      'user_id': userId,
      'item_id': item.id,
    });
    if (response.statusCode != 200) {
      throw Exception('Fehler beim Hinzufügen des Items zum Inventar: ${response.statusCode}');
    }
  }



}