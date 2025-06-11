import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";


class UserManager {

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