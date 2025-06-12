import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";
import "package:laendle_guessr/services/api_service.dart";


class UserManager {
  UserManager._internal(this.apiService);
  static final UserManager _instance = UserManager._internal(ApiService.instance);
  factory UserManager() => _instance;
  static UserManager get instance => _instance;

  final ApiService apiService;
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