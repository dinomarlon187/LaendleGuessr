import 'package:laendle_guessr/data_objects/city.dart';


class Quest {
  final int qid;
  final String image;
  final City city;

  Quest({
    required this.qid,
    required this.image,
    required this.city,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      qid: json['qid'],
      image: json['image'],
      city: CityExtension.fromId(json['city']),
    );
  }
}