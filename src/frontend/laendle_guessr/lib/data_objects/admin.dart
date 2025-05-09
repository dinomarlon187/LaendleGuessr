import 'account.dart';

class Admin extends Account {
  String aid;

  Admin({
    required String username,
    required String email,
    required String coins,
    required this.aid,
  }) : super(username: username, email: email, coins: 9223372036854775807);
}