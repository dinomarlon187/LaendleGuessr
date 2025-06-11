import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'dart:async';
import 'package:laendle_guessr/services/item_service.dart';

class Inventory{
  List<Item> items;
  final ItemService itemService = ItemService.instance;

  Inventory({List<Item>? items}) : items = items ?? [];

  void addItemToInventory(Item item, User user) async {
    items.add(item);
    await itemService.addItemToInventory(user.uid, item).then((_) {
    }).catchError((error) {
      // Logging
    });
    
  }
  //get Items from user, addItemToInv, db connection in item_service.dart

  Future<List<Item>> getAllItemsFromUser(User user) async {
    await itemService.getAllItemsByUser(user.uid).then((fetchedItems) {
      items = fetchedItems;
    }).catchError((error) {
      // Logging
    });
    return items;
  }
  Future<Item> getItemById(int itemId) async {
    Item item = Item(id: itemId, name: '', price: 0, image: '');
    await itemService.getItemById(itemId).then((fetchedItem) {
      item = fetchedItem;
    }).catchError((error) {
      // Logging
    });
    return item;
  }

  Future<List<Item>> getAllItems() async {
    return await itemService.getAllItems();
  }
}