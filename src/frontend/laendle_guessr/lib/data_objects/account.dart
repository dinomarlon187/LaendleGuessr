abstract class Account{
  final int uid;
  final String username;
  final bool isAdmin;
  final String password;



  Account({
    required this.uid,
    required this.username,
    required this.isAdmin,
    required this.password
  });
}