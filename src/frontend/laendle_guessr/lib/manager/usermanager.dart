import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";
import "package:laendle_guessr/services/api_service.dart";
import "package:laendle_guessr/services/user_service.dart";
import "package:laendle_guessr/data_objects/item.dart";
import "package:laendle_guessr/manager/questmanager.dart";
import "package:laendle_guessr/manager/inventory.dart";
import "package:laendle_guessr/data_objects/city.dart";
import "package:flutter/material.dart";




class UserManager extends ChangeNotifier{
  UserManager._internal(this.apiService);
  static final UserManager _instance = UserManager._internal(ApiService.instance);
  factory UserManager() => _instance;
  static UserManager get instance => _instance;

  final ApiService apiService;
  User? currentUser;

  Future<void> loginUser(User user) async {
    currentUser = user;
    await QuestManager.instance.loadQuests();
  }

  Future<bool> login(String username, String password) async {
    final success = await UserService().checkCredentials(username, password);

    if (success) {

      final userJson = await UserService().getAllUsers();
      final userMap = userJson.firstWhere((u) => u['username'] == username);
      final user = User.fromJson(userMap);
      await loginUser(user);

      return true;
    }

    return false;
  }



  void logoutUser(){
    currentUser = null;
  }

  void completeQuest(User user, Quest quest) {
  }

  Future<bool> buyItem(Item item) async {
    if (currentUser == null) return false;

    if (currentUser!.coins >= item.price) {
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
      return true;
    } else {
      return false;
    }
  }

  bool ownsItem(Item item) {
    return currentUser?.inventory.items.any((owned) => owned.id == item.id) ?? false;
  }
}