import 'package:laendle_guessr/services/logger.dart';

class Item {
  final int id;
  final String image;
  final String name;
  final int price;

  Item({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
  }) {
    AppLogger().log('Item erstellt: $name (ID: $id, Preis: $price)');
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    AppLogger().log('Item.fromJson(): Erstelle Item ${json['name']} aus JSON');
    return Item(
      id: json['iid'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
    );
  }
}
