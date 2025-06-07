import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';


class AppController {
  final LocationChecker locationChecker;
  final QuestManager questManager;
  final UserManager userManager;

  AppController(this.locationChecker, this.questManager, this.userManager);
}