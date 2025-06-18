import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";
import "package:laendle_guessr/services/api_service.dart";
import "package:laendle_guessr/services/user_service.dart";
import "package:laendle_guessr/data_objects/item.dart";
import "package:laendle_guessr/manager/questmanager.dart";
import "package:laendle_guessr/manager/inventory.dart";
import "package:laendle_guessr/data_objects/city.dart";
import "package:flutter/material.dart";
import 'package:laendle_guessr/services/logger.dart';



class UserManager extends ChangeNotifier{
  UserManager._internal(this.apiService) {
    AppLogger().log('UserManager instanziiert');
  }
  static final UserManager _instance = UserManager._internal(ApiService.instance);
  factory UserManager() => _instance;
  static UserManager get instance => _instance;

  final ApiService apiService;
  User? currentUser;

  Future<void> loginUser(User user) async {
    AppLogger().log('UserManager: loginUser() für User ${user.username}');
    currentUser = user;
    AppLogger().log('UserManager: Lade Quests für User ${user.username}');
    await QuestManager.instance.loadQuests();
    AppLogger().log('UserManager: User ${user.username} erfolgreich eingeloggt');
  }

  Future<bool> login(String username, String password) async {
    AppLogger().log('UserManager: login() für Benutzer: $username');
    final success = await UserService().checkCredentials(username, password);

    if (success) {
      AppLogger().log('UserManager: Credentials erfolgreich verifiziert für $username');

      final userJson = await UserService().getAllUsers();
      final userMap = userJson.firstWhere((u) => u['username'] == username);
      final user = User.fromJson(userMap);
      await loginUser(user);

      AppLogger().log('UserManager: Login erfolgreich abgeschlossen für $username');
      return true;
    }

    AppLogger().log('UserManager: Login fehlgeschlagen für $username');
    return false;
  }

  void logoutUser(){
    AppLogger().log('UserManager: logoutUser() aufgerufen');
    if (currentUser != null) {
      AppLogger().log('UserManager: User ${currentUser!.username} wird ausgeloggt');
    }
    currentUser = null;
    AppLogger().log('UserManager: Logout abgeschlossen');
  }

  void completeQuest(User user, Quest quest) {
    AppLogger().log('UserManager: completeQuest() für User ${user.username}');
  }

  Future<bool> buyItem(Item item) async {
    AppLogger().log('UserManager: buyItem() für Item ${item.name} (Preis: ${item.price})');
    if (currentUser == null) {
      AppLogger().log('UserManager: Kein User eingeloggt, Kauf abgebrochen');
      return false;
    }

    if (currentUser!.coins >= item.price) {
      AppLogger().log('UserManager: Genügend Coins vorhanden, Item wird gekauft');
      currentUser!.coins -= item.price;
      Map<String, dynamic> updatedUserData = await UserService().updateUser(
        uid: currentUser!.uid,
        coins: currentUser!.coins,
        username: currentUser!.username,
        password: currentUser!.password,
        city: currentUser!.city.id,
        admin: false,
      );
      currentUser!.inventory.addItemToInventory(item);
      notifyListeners();
      AppLogger().log('UserManager: Kauf erfolgreich, Item ${item.name} wurde hinzugefügt');
      return true;
    } else {
      AppLogger().log('UserManager: Nicht genügend Coins für den Kauf von ${item.name}');
      return false;
    }
  }

  bool ownsItem(Item item) {
    return currentUser?.inventory.items.any((owned) => owned.id == item.id) ?? false;
  }
}