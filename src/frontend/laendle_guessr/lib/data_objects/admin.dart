import "package:laendle_guessr/data_objects/account.dart";


class Admin extends Account {
  Admin({
    required String uid,
    required String username,
    required String password,
  }) : super(uid: uid, username: username, password: password, isAdmin: true);
}