import 'package:laendle_guessr/services/api_service.dart';
import 'dart:convert';
import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/services/logger.dart';

/// Service für Item-bezogene API-Aufrufe.
//
/// Diese Klasse kapselt alle API-Operationen rund um Items (z.B. Items laden, einem User zuweisen)
/// und nutzt den ApiService für die HTTP-Kommunikation mit dem Backend.
class ItemService {
  static final ItemService _instance = ItemService._internal(ApiService.instance);
  factory ItemService() {
    AppLogger().log('ItemService instanziiert');
    return _instance;
  }
  ItemService._internal(this.api);
  final ApiService api;
  static ItemService get instance => _instance;

  Future<List<Item>> getAllItems() async {
    AppLogger().log('ItemService: getAllItems() aufgerufen');
    final response = await api.get('item');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final items = jsonList.map((jsonItem) => Item.fromJson(jsonItem)).toList();
      AppLogger().log('ItemService: ${items.length} Items erfolgreich geladen');
      return items;
    } else {
      AppLogger().log('ItemService: Fehler beim Laden aller Items - Status: ${response.statusCode}');
      throw Exception('Hallo: ${response.statusCode}');
    }
  }

  Future<List<Item>> getAllItemsByUser(int userId) async {
    AppLogger().log('ItemService: getAllItemsByUser() für User $userId');
    final response = await api.get('all_item_user/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final items = jsonList.map((jsonItem) => Item.fromJson(jsonItem)).toList();
      AppLogger().log('ItemService: ${items.length} Items für User $userId geladen');
      return items;
    } else {
      AppLogger().log('ItemService: Fehler beim Laden der Items für User $userId - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden aller Items eines Users: ${response.statusCode}');
    }
  }

  Future<Item> getItemById(int itemId) async {
    AppLogger().log('ItemService: getItemById() für Item $itemId');
    final response = await api.get('item/$itemId');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final item = Item.fromJson(json);
      AppLogger().log('ItemService: Item $itemId erfolgreich geladen: ${item.name}');
      return item;
    } else {
      AppLogger().log('ItemService: Fehler beim Laden von Item $itemId - Status: ${response.statusCode}');
      throw Exception('Fehler beim Laden des Items: ${response.statusCode}');
    }
  }

  Future<void> addItemToInventory(int userId, Item item) async {
    AppLogger().log('ItemService: addItemToInventory() für User $userId, Item ${item.name}');
    final response = await api.post('item_user', {
      'uid': userId,
      'id': item.id,
    });
    if (response.statusCode != 200) {
      AppLogger().log('ItemService: Fehler beim Hinzufügen von Item ${item.name} zu User $userId - Status: ${response.statusCode}');
      throw Exception('Fehler beim Hinzufügen des Items zum Inventar: ${response.statusCode}');
    }
    AppLogger().log('ItemService: Item ${item.name} erfolgreich zu User $userId hinzugefügt');
  }
}