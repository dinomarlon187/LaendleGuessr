import 'package:flutter_test/flutter_test.dart';
import 'package:laendle_guessr/controller/appcontroller.dart';
import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';

void main() {
  test('AppController singleton and dependencies', () {
    final ac = AppController.instance;
    expect(ac, isNotNull);
    expect(ac.userManager, UserManager.instance);
    expect(ac.questManager, QuestManager.instance);
    expect(ac.locationChecker, LocationChecker.instance);
  });
}