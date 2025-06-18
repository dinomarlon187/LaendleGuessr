import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/data_objects/city.dart';

void main() {
  test('City id values', () {
    expect(City.bregenz.id, 0);
    expect(City.dornbirn.id, 1);
    expect(City.hohenems.id, 2);
    expect(City.feldkirch.id, 3);
    expect(City.bludenz.id, 4);
  });
  test('City fromId returns correct enum', () {
    expect(CityExtension.fromId(0), City.bregenz);
    expect(CityExtension.fromId(1), City.dornbirn);
    expect(CityExtension.fromId(2), City.hohenems);
    expect(CityExtension.fromId(3), City.feldkirch);
    expect(CityExtension.fromId(4), City.bludenz);
  });
  test('City fromId invalid throws', () {
    expect(() => CityExtension.fromId(5), throwsException);
  });
}
