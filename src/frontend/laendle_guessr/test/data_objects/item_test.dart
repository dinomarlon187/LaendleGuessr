import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/data_objects/item.dart';

void main() {
  test('Item.fromJson parses correctly', () {
    final json = {
      'iid': 7,
      'image': 'item.png',
      'name': 'TestItem',
      'price': 100
    };
    final item = Item.fromJson(json);
    expect(item.id, 7);
    expect(item.image, 'item.png');
    expect(item.name, 'TestItem');
    expect(item.price, 100);
  });
}
