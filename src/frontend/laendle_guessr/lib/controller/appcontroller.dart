import 'package:laendle_guessr/manager/usermanager.dart';
import 'package:laendle_guessr/manager/questmanager.dart';
import 'package:laendle_guessr/services/locationchecker.dart';


class AppController {
  late UserManager userManager;
  late LocationChecker locationChecker;

  AppController() {
    userManager = UserManager();
    locationChecker = LocationChecker();
  }
}