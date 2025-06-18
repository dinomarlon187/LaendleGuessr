import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/city.dart';

void main() {
  test('User fromJson creates valid User', () {
    final json = {
      'uid': 1,
      'username': 'test',
      'password': 'pass',
      'coins': 10,
      'city': 2,
      'admin': true
    };
    final user = User.fromJson(json);
    expect(user.uid, 1);
    expect(user.username, 'test');
    expect(user.password, 'pass');
    expect(user.coins, 10);
    expect(user.city, City.hohenems);
    expect(user.isAdmin, true);
  });
}
