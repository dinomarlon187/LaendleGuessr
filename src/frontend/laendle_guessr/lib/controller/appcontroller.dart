import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';


class AppController {
  AppController._internal(this.locationChecker, this.questManager, this.userManager);

  static final AppController _instance = AppController._internal(
    LocationChecker.instance,
    QuestManager.instance,
    UserManager.instance,
  );

  factory AppController() => _instance;

  static AppController get instance => _instance;

  final LocationChecker locationChecker;
  final QuestManager questManager;
  final UserManager userManager;

}