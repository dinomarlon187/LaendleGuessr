class Item{
  final int id;
  final String name;
  final String image;
  final int price; 

  Item({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['iid'],
      name: json['name'],
      image: json['image'],
      price: json['price'],
    );
  }
}