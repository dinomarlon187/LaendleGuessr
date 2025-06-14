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
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['iid'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
    );
  }
}
