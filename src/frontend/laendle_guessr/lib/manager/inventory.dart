import 'package:laendle_guessr/data_objects/item.dart';

class Inventory{
  List<Item> items;

  Inventory({List<Item>? items}) : items = items ?? [];

  void addItem(Item item) {
    items.add(item);
  }
}