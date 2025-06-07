import 'package:laendle_guessr/data_objects/city.dart';


class Quest {
  final int id;
  final String image;
  final City city;

  Quest({
    required this.id,
    required this.image,
    required this.city,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      image: json['image'],
      city: json['city'],
    );
  }
}