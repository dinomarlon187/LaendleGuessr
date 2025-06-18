import 'package:laendle_guessr/data_objects/city.dart';
import 'package:laendle_guessr/services/logger.dart';


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
  }) {
    AppLogger().log('Quest erstellt: QID $qid in ${city.name} ($latitude, $longitude)');
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    AppLogger().log('Quest.fromJson(): Erstelle Quest QID ${json['qid']} aus JSON');
    return Quest(
      qid: json['qid'],
      image: json['image'],
      city: CityExtension.fromId(json['city']),
      latitude: double.parse(json['coordinates'].split(',')[0]),
      longitude: double.parse(json['coordinates'].split(',')[1]),
    );
  }
}