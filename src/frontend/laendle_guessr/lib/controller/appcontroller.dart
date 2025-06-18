import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';
import 'package:laendle_guessr/services/logger.dart';


class AppController {
  AppController._internal(this.locationChecker, this.questManager, this.userManager) {
    AppLogger().log('AppController instanziiert');
    AppLogger().log('AppController: LocationChecker, QuestManager und UserManager initialisiert');
  }

  static final AppController _instance = AppController._internal(
    LocationChecker.instance,
    QuestManager.instance,
    UserManager.instance,
  );

  factory AppController() {
    AppLogger().log('AppController: Factory-Methode aufgerufen');
    return _instance;
  }

  static AppController get instance {
    AppLogger().log('AppController: getInstance() aufgerufen');
    return _instance;
  }

  final LocationChecker locationChecker;
  final QuestManager questManager;
  final UserManager userManager;

}