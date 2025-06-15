import "package:laendle_guessr/data_objects/quest.dart";
import "package:laendle_guessr/data_objects/user.dart";
import "package:laendle_guessr/services/api_service.dart";
import "package:laendle_guessr/services/user_service.dart";


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

  Future<bool> login(String username, String password) async {
    final success = await UserService(apiService).checkCredentials(username, password);

    if (success) {

      final userJson = await UserService(apiService).getAllUsers();
      final userMap = userJson.firstWhere((u) => u['username'] == username);
      final user = User.fromJson(userMap);
      loginUser(user);

      return true;
    }

    return false;
  }



  void logoutUser(){
    currentUser = null;
  }

  void completeQuest(User user, Quest quest) {
  }
}