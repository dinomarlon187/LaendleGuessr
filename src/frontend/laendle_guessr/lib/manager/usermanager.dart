import "package:laendle_guessr/manager/questmanager.dart";
import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";


class UserManager {
  final QuestManager questManager;

  UserManager(this.questManager);

  User? currentUser;

  void loginUser(User user) {
    currentUser = user;
  }
  void logoutUser(){
    currentUser = null;
  }

  void completeQuest(User user, Quest quest) {
  }
}