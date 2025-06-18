import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/data_objects/account.dart';

class DummyAccount extends Account {
  DummyAccount({required int uid, required String username, required bool isAdmin, required String password})
      : super(uid: uid, username: username, isAdmin: isAdmin, password: password);
}

void main() {
  test('Account fields are set properly', () {
    final acc = DummyAccount(uid: 10, username: 'u', isAdmin: false, password: 'p');
    expect(acc.uid, 10);
    expect(acc.username, 'u');
    expect(acc.isAdmin, false);
    expect(acc.password, 'p');
  });
}
