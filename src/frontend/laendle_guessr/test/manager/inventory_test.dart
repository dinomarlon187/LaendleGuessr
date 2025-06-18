import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/manager/inventory.dart';
import 'package:laendle_guessr/data_objects/item.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/manager/usermanager.dart';

void main() {
  test('Inventory default items empty', () {
    final inventory = Inventory();
    expect(inventory.items, isEmpty);
  });

  test('addItemToInventory adds item', () {
    final inventory = Inventory();
    final item = Item(id: 1, image: 'img', name: 'n', price: 0);
    UserManager.instance.currentUser = User(uid: 1, username: 'u', password: 'p', isAdmin: false, city: City.bregenz, coins: 0);
    inventory.addItemToInventory(item);
    expect(inventory.items, contains(item));
  });
}
