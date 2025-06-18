import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/data_objects/quest.dart';
import 'package:laendle_guessr/data_objects/city.dart';

void main() {
  test('Quest.fromJson parses correctly', () {
    final json = {
      'qid': 42,
      'image': 'quest.png',
      'city': 1,
      'coordinates': '47.123,9.123'
    };
    final quest = Quest.fromJson(json);
    expect(quest.qid, 42);
    expect(quest.image, 'quest.png');
    expect(quest.city, City.dornbirn);
    expect(quest.latitude, 47.123);
    expect(quest.longitude, 9.123);
  });
}
