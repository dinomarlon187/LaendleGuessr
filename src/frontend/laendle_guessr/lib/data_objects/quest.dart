import 'package:laendle_guessr/data_objects/city.dart';


class Quest {
  final int qid;
  final String image;
  final City city;
  final double latitude;
  final double longitude; 

  Quest({
    required this.qid,
    required this.image,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      qid: json['qid'],
      image: json['image'],
      city: CityExtension.fromId(json['city']),
      latitude: double.parse(json['coordinates'].split(',')[0]),
      longitude: double.parse(json['coordinates'].split(',')[1]),
    );
  }
}