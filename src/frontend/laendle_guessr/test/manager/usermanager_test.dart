import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/data_objects/user.dart';
import 'package:laendle_guessr/data_objects/city.dart';

void main() {
  test('logoutUser clears currentUser', () {
    final um = UserManager.instance;
    um.currentUser = User(uid: 1, username: 'u', password: 'p', isAdmin: false, city: City.bregenz, coins: 0);
    um.logoutUser();
    expect(um.currentUser, null);
  });
}
