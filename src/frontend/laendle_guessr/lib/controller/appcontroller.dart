import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';


class AppController {
  final QuestManager questManager = QuestManager();
  late final UserManager userManager;

  AppController() {
    userManager = UserManager(questManager);
  }

  
}